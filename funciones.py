class Descarga:
    # Función para guardar los datos de un buffer dentro de un repositorio
    def upload(self,ruta,archivo,extension,buffer):
        from google.cloud import storage

        cliente=storage.Client(project='desafio-tecnico-477604')
        bucket=cliente.bucket('rockingdata')
        blob=bucket.blob(f'{ruta}/{archivo}.{extension}')

        blob.upload_from_string(buffer.getvalue(),content_type='text/csv')

    # Función para descargar archivos de un repositorio y guardarlo dentro de otro
    def descargar_aws(self,rep_origen,rep_dest,titulo,tipo,div):
        import pandas as pd
        from io import StringIO

        ds=Descarga()

        response=pd.read_csv(f'{rep_origen}/{titulo}.{tipo}',sep=div)
        response=response.fillna('')
        csv_buffer=StringIO()
        response.to_csv(csv_buffer,sep=';',index=False)
        ds.upload(rep_dest,titulo,tipo,csv_buffer)

    # Función para descargar la información de un archivo de un repositorio y devolverlo en un buffer
    def descargar_gc(self,ruta,archivo,extension):
        from google.cloud import storage
        from io import StringIO
        import pandas as pd

        cliente=storage.Client(project='desafio-tecnico-477604')
        bucket=cliente.bucket('rockingdata')
        blob=bucket.blob(f'{ruta}/{archivo}.{extension}')

        contenido=blob.download_as_text()
        return pd.read_csv(StringIO(contenido),sep=';',keep_default_na=False,dtype=str)
    
class Qa:
    def try_parse(self,cadena,tipo):
        from datetime import datetime

        if tipo == 'int':
            try:
                return int(cadena)
            except ValueError:
                return -2
        
        if tipo == 'date':
            try:
                fecha = datetime.strptime(cadena,'%B %d, %Y').strftime('%Y-%m-%d')
                return True
            except ValueError:
                return False
                

    def control(self,archivo):
        from datetime import datetime 

        ds=Descarga()
        qa=Qa()

        contenido = ds.descargar_gc('landing',archivo,'csv') 
        cabezales=list(contenido.columns)
        ctrl={c:{'vacios':0,'ids_vacios':[],'corruptos':0,'ids_corruptos':[],'max':0} for c in cabezales}

        i=0
        linea={'show_id':'s0'}
        while i < len(contenido):
            prelinea = linea
            linea=contenido.iloc[i]
            for c in cabezales:
                ext=len(linea[c])
                # Evaluamos la cantidad de registros vacios proceden de los csv
                if ext==0:
                    ctrl[c]['vacios']=ctrl[c]['vacios']+1
                    ctrl[c]['ids_vacios'].append(i)
                # Buscamos la longitud máxima de caracteres que tiene cada campo
                elif ext > ctrl[c]['max']:
                    ctrl[c]['max']=ext

                # Evaluamos qué show_id no incrementa de 1 a 1
                if c=='show_id':
                    if linea[c][0] != 's' or qa.try_parse(linea[c][1:],'int') != qa.try_parse(prelinea[c][1:],'int') + 1:
                        ctrl[c]['corruptos']=ctrl[c]['corruptos']+1
                        ctrl[c]['ids_corruptos'].append(i)
                # Evaluamos qué type no corresponde a Movie o TV Show
                elif c=='type':
                    if linea[c] not in ('Movie','TV Show'):
                        ctrl[c]['corruptos']=ctrl[c]['corruptos']+1
                        ctrl[c]['ids_corruptos'].append(i)
                # Evaluamos qué date_added no respeta el formato de fecha
                elif c == 'date_added':
                    if not qa.try_parse(linea[c],'date'):
                        ctrl[c]['corruptos']=ctrl[c]['corruptos']+1
                        ctrl[c]['ids_corruptos'].append(i)
                # Evaluamos qué realease_year es un número menor a 1887 o mayor al año corriente
                elif c == 'realease_year':
                    ry=qa.try_parse(linea[c],'int')
                    if ry < 1887 or ry > datetime.now().year:
                        ctrl[c]['corruptos']=ctrl[c]['corruptos']+1
                        ctrl[c]['ids_corruptos'].append(i)
                # Evaluamos qué duration es un número menor a 0
                elif c == 'duration' and i == 0:
                    if not(qa.try_parse(linea[c].split(' ')[0],'int') >= 0 and ((linea['type'] == 'Movie' and linea[c].split(' ')[1]=='min') or (linea['type'] == 'TV Show' and linea[c].split(' ')[:-1]=='Season'))):
                        ctrl[c]['corruptos']=ctrl[c]['corruptos']+1
                        ctrl[c]['ids_corruptos'].append(i)
            i+=1

        return ctrl

    # Los datos provenientes de los controles, se cargan en un csv dentro del subdirectorio controles
    def archivo_control(self,archivo):
        import csv
        from io import StringIO

        ds=Descarga()
        qa=Qa()

        ctrl = qa.control(archivo)
        csv_buffer=StringIO()

        writer = csv.writer(csv_buffer,delimiter=';')
        writer.writerow(['campo','vacios','ids_vacios','corruptos','ids_corruptos','max'])
        for campo, valores in ctrl.items():
            writer.writerow([campo,valores['vacios'],valores['ids_vacios'],valores['corruptos'],valores['ids_corruptos'],valores['max']])

        ds.upload('controles',archivo,'csv',csv_buffer)

class Ingenieria():
    # Función para pasar los registros del subdirectorio landing a la base de datos raw
    def lan_raw(self,plataforma):
        from conexion import conexion
        import sqlalchemy
        from datetime import datetime

        ds=Descarga()
        qa=Qa()

        fecha_carga=str(datetime.now())

        datos=ds.descargar_gc('landing',f'{plataforma}_titles','csv')
        datos=datos.fillna('')

        # Dado que show_id es una de las PK en la capa cur, debemos implementar este filtro
        filtro = datos['show_id'].str.startswith('s') & datos['show_id'].str[1:].apply(lambda x: qa.try_parse(x,'int') >= 0)
        datos_fil = datos[filtro].copy()
        datos_fil['plataforma'] = plataforma
        datos_fil['fecha_carga'] = fecha_carga
        datos_fil.rename(columns={'cast':'cast_','type':'type'},inplace=True)

        conn=conn=conexion('raw')
        engine=sqlalchemy.create_engine('mssql+pytds://',creator=lambda:conn)

        datos_fil.to_sql('titulos',schema='dbo',con=engine,if_exists='append',index=False)

    # Función para pasar los registros de la capa raw a la capa de curado
    def raw_cur(self,plataforma,tabla):
        from conexion import conexion
        import sqlalchemy

        file=open(f'queries/upsert_{tabla}.sql','r',encoding='utf-8')
        query=file.read().replace('$CANAL',plataforma)
        query=sqlalchemy.text(query)

        conn=conexion('cur')
        engine=sqlalchemy.create_engine(
                'mssql+pytds://',
                creator=lambda: conn,
                connect_args={
                    'login_timeout':60,
                    'timeout':300
                }
            )
        cursor=engine.connect()
        cursor.execute(query)
        cursor.commit()
        cursor.close()