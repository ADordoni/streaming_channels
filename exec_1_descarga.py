from funciones import Descarga
import os, yaml

ds=Descarga()

requerimientos=[]
archivos = os.listdir('requerimientos')
for archivo in archivos:
    if archivo.endswith('.yaml'):
        file = open(f'requerimientos/{archivo}')
        pedido=yaml.safe_load(file)
        requerimientos.append(pedido)

for requerimiento in requerimientos:
    repo = requerimiento['repositorio']

    for f in requerimiento['archivos']:
        plataforma, sufijo, extension, separador = f['plataforma'], f['sufijo'], f['extension'], f['separador']
        ds.descargar_aws(repo,'landing',f'{plataforma}{sufijo}',extension, separador)