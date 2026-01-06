from funciones import Ingenieria
import os, yaml

ing=Ingenieria()

requerimientos=[]
archivos = os.listdir('requerimientos')
for archivo in archivos:
    if archivo.endswith('.yaml'):
        file = open(f'requerimientos/{archivo}')
        pedido=yaml.safe_load(file)
        requerimientos.append(pedido)

for requerimiento in requerimientos:

    for f in requerimiento['archivos']:
        plataforma = f['plataforma']
        ing.lan_raw(plataforma)