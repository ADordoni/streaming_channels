def conexion(db):
    from google.cloud.sql.connector import Connector

    conexion=Connector()

    clave = ''
    servidor=''

    return conexion.connect(servidor,'pytds',user='sqlserver',password=clave,db=db)