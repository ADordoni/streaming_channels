from funciones import Qa
import os, yaml

qa=Qa()

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
        plataforma, sufijo = f['plataforma'], f['sufijo']
        qa.archivo_control(f'{plataforma}{sufijo}')
