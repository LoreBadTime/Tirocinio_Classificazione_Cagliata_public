from PIL import Image
import os
import shutil
import random
import math,time
import subprocess

# input ->  set i set sono i set da escludere nel merge è una lista, basedir path dove sono contenuti tutti i set    
# output -> creazione set unico 20 
def merge_datasets(set,basedir):
    originalset = [str(x) for x in range(0,17,1)]
    num = [str(x) for x in set]
    # rimozione set 20,set 27 delle iterazioni precedenti
    try:
        shutil.rmtree(str(basedir + '\\Set_20'))
    except:
        pass
    try:
        shutil.rmtree(str(basedir + '\\Set_27'))
    except:
        pass
    # impostazione set 20 come set di arrivo di tutti i merge
    tempsecondset = "20"
    tipi = ['Positive','Negative']
    imgtype = ['_Enhanced','_LocEntropy','_LocStD','_Original']
    

    
    for x in originalset:
      try:  
        # num contiene i set che non entreranno a fare parte dei merge
        if(x in num):
            raise Exception()
        # copia del set scelto per l'iterazione nei set 20(prima iterazione) o 27 alle restanti iterazioni
        shutil.copytree(basedir + '\\Set_'+
                     x +'\\',basedir + '\\Set_'+ tempsecondset +'\\')
        
        # impostazione directory per le rinomine dei file 
        set = basedir + '\\Set_'+ tempsecondset +'\\'
        set_string = set[-7:-1]
        chosen_set = set + set_string
        # rinomina del set di partenza nel set 27(questo per la sottocartella
        # ex Set_27/Set_5_Enhanced -> Set_27/Set_27_Enhanced)
        for i in imgtype:
            
            os.rename(
                str(basedir + '\\Set_'+ tempsecondset +'\\Set_'+ x + i),
                str(basedir + '\\Set_'+ tempsecondset +'\\Set_'+ tempsecondset + i)
            )

        i = None
        e = None
        filelist = []
        tempsecondset = "27"
        try:
         for e in imgtype:
            for i in tipi:
                for file in os.listdir(str(basedir + '\\Set_'+
                                        tempsecondset +'\\Set_'+ tempsecondset +  e +'\\'+ i +'\\')):
                    f = file[-8:-4]
                    typefile2 = e.split("_")[1]


                    #spostamento dei singoli file dal set 27 al set 20
                    shutil.move(
                    str(basedir + '\\Set_'+
                                        tempsecondset +'\\Set_'+ tempsecondset + e + '\\'+ i +'\\' + typefile2 + '___DSC_'+ f +'.JPG' ),
                    str(basedir + '\\Set_'+
                                        "20" +'\\Set_'+ "20" + e + '\\'+ i +'\\' + typefile2 + '___DSC_'+ f + e + x +'.JPG' ))
        # rimozione set 27 dopo la singola iterazione
         shutil.rmtree(str(basedir + '\\Set_'+ tempsecondset))
        except:
            pass
        try:
            shutil.rmtree(str(basedir + '\\Set_' + tempsecondset))
        except:
            pass
      except:
          pass
    # non serve
    print(x)
    filelist = []
    e = None
    i = None
    f = None
    

# input  -> basedir path dove sono contenuti tutti i set    
# output -> set 23 che contiene immagini estratte a campioni regolari dal set 20 
def discretize_set(basedir,toDiscretiza,divisionNeg, divisionPos):
    originalset = str(toDiscretiza)
    setnum = "23"

    shutil.copytree(basedir + '\\Set_'+
                     originalset +'\\',basedir + '\\Set_'+ setnum +'\\')


    set = basedir + '\\Set_'+ setnum +'\\'
    set_string = set[-7:-1]
    chosen_set = set + set_string
    tipi = ['Positive','Negative']
    imgtype = ['_Enhanced','_LocEntropy','_LocStD','_Original']
    for i in imgtype:
        os.rename(
            str(basedir + '\\Set_'+ setnum +'\\Set_'+originalset + i),
            str(basedir + '\\Set_'+ setnum +'\\Set_'+setnum + i)
        )

    e = None
    i = None
    try:
        for e in imgtype:
            for i in tipi:
                filelist = []
                j = 0

                allfiles = os.listdir(chosen_set + e+'\\'+ i +'\\')
                if(i == 'Negative'):
                    inti = int(len(allfiles) / divisionNeg)
                else:
                    inti = int(len(allfiles) / divisionPos)
                while(j < len(allfiles)):
                    if(j % inti != 1):
                        os.remove(chosen_set + e +'\\'+ i +'\\' + allfiles[j])
                    j += 1 

    except Exception (e):
        print(e)
    
# input ->  i set da escludere nell'unione dei dataset e il numero di immagini dal centro
# output -> set20 con i dataset uniti e con una sottocartella del 
#           set20 che contiene un subset del set20 che contiene le 
#           immagini più al centro di ogni set (set20/set_20_test)
def merge_dataset_from_center(set,basedir,numimages):
    k2 = numimages
    originalset = [str(x) for x in range(17,1,-1)]
    num = set
    
    try:
        shutil.rmtree(str(basedir + '\\Set_20'))
    except:
        pass
    try:
        shutil.rmtree(str(basedir + '\\Set_27'))
    except:
        pass
    tempsecondset = "20"
    
    tipi = ['Positive','Negative']
    imgtype = ['_Enhanced','_LocEntropy','_LocStD','_Original']
    
    num = [str(x) for x in num]

    
    for x in originalset:
      try:  
        if(x in num):
            raise Exception()
        try:
            shutil.copytree(basedir + '\\Set_'+
                     x +'\\',basedir + '\\Set_'+ tempsecondset +'\\')
        except FileNotFoundError:
            raise Exception()

        set = basedir + '\\Set_'+ tempsecondset +'\\'
        set_string = set[-7:-1]
        chosen_set = set + set_string
        for i in imgtype:
            
            os.rename(
                str(basedir + '\\Set_'+ tempsecondset +'\\Set_'+ x + i),
                str(basedir + '\\Set_'+ tempsecondset +'\\Set_'+ tempsecondset + i)
            )

        i = None
        e = None
        filelist = []
        
        
        for e in imgtype:
            for i in tipi:
                try:
                    os.makedirs(basedir + '\\Set_'+
                                        "20" +'\\Set_20_Train\\'+ e + '\\' + i)
                except:
                    pass
                allfiles = os.listdir(str(basedir + '\\Set_'+
                                        tempsecondset +'\\Set_'+ tempsecondset +  e +'\\'+ i +'\\'))
                filelist = []
# k indica quanti campioni estrarre dal centro
                if(i == 'Negative'):
                    k = 1
                    while k <= k2:
                        filelist.append(allfiles[-k][-8:-4])
                        k += 1
                else:   
                    k = 0
                    while k <= k2-1:
                        filelist.append(allfiles[k][-8:-4])
                        k += 1
                
                for file in allfiles:
                    
                    f = file[-7:-4]#8,4
                    typefile2 = e.split("_")[1]
                    
                    if f in filelist:
                        os.rename(str(basedir + '\\Set_'+
                                        tempsecondset +'\\Set_'+ tempsecondset +  e +'\\'+ i +'\\'
                                        #+ typefile2+'___DSC_'
                                        + f +'.JPG'),
                        str(basedir + '\\Set_'+
                                        "20" +'\\Set_20_Train\\'+ e +'\\'+ i +'\\'
                                        #+ typefile2+'___DSC_'
                                        + f + e + x +'.JPG'))
                    else:
                        shutil.move(
                    str(basedir + '\\Set_'+
                                        tempsecondset +'\\Set_'+ tempsecondset + e + '\\'+ i +'\\'
                                          #+ typefile2 + '___DSC_'
                                          + f +'.JPG' ),
                    str(basedir + '\\Set_'+
                                        "20" +'\\Set_'+ "20" + e + '\\'+ i +'\\'
                                          #+ typefile2 + '___DSC_'
                                          + f + e + x +'.JPG' ))
        tempsecondset = "27"
        shutil.rmtree(str(basedir + '\\Set_'+ tempsecondset))
        try:
            shutil.rmtree(str(basedir + '\\Set_' + tempsecondset))
        except:
            pass
      except:
          pass
    print(x)
    filelist = []




if __name__ == '__main__' :
    basedir = os.path.dirname(os.path.abspath(__file__))
    
    basedir = basedir+'\\1_Processed\\'
    
    #merge_dataset_from_center([10,13,11,12],basedir)
    
    num = 15

    # il codice quà era un ciclo per iterare il processo di reporting
    # merge dataset preimpostato per fungere con il set 5
    #merge_dataset_from_center([3,4,6,7,8,9,10,11,12,13,14,16],basedir,3)
    merge_datasets([5],basedir)
    #discretize_set(basedir,20,2,2)
    #while num < 16:
    if(False):
       #if(num in [4,5,6,9,10,11,12,13,14,15]):
            merge_datasets([num],basedir)
    #discretize_set20(basedir)
            # lancio reporting con tutti i filtri
            subprocess.Popen("F:\\Download\\Tirocinio-Classificazione-Cagliata\\send_all_reports.bat " + str(num))
            # uso del timer perchè controllare il termine dei 
            # processi richiederebbe troppo tempo di sviluppo
            time.sleep(5700)
            num += 1

