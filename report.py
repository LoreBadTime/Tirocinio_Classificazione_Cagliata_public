
#from __future__ import print_function
import os.path
import math
import requests as rq
#from google.auth.transport.requests import Request
#from google.oauth2.credentials import Credentials
#from google_auth_oauthlib.flow import InstalledAppFlow
#from googleapiclient.discovery import build
#from googleapiclient.errors import HttpError
# Da quì poi invio il report direttamente a drive dopo
import time,sys
#import numpy as np
#import pandas
SCOPES = ['https://www.googleapis.com/auth/spreadsheets']

# funzioni di supporto per reporting automatizzato

#FILE = ''


def get_report(file):
    a = None
    with open(file,"r") as report:
        a = report.read()
    return a

# prima versione parser di reporting
def sendreport_full(unparsed_str,send_spreadsheet):
    rows = unparsed_str.splitlines()
    del rows[0]
    requestbody = []
    for line in rows:
        requestbody.append(line.split(','))
    requestbody.append(["-----","-----","-----","-----","-----","-----"])
    body = {"values": requestbody}
    request = send_spreadsheet.values().append(spreadsheetId=FILE, range="A:F", valueInputOption="RAW", insertDataOption="INSERT_ROWS", body = body)
    response = request.execute()
# attuale versione usata per reporitg
def sendreport_v2(unparsed_str,send_spreadsheet,f):
    rows = unparsed_str.splitlines()
    requestbody = []
    line_size = len(rows)
    avg = 3
    avg_type = { 3 : "macroavg",4 : "microavg",5:"weightedavg"}
    k = 3
    while(k < 6):
        avg = k
        line_size = len(rows)
        requestbody.append( [avg_type[avg],"","","","","","","",""])
        requestbody.append([reportfile,"classificatore","accuracy","precision","recall","specificity","fscore","MCC","BACC"])
        i = 2
        j = 0
        num_classificatori = int((rows[1].split(','))[0],10)
        num_modelli = int((rows[1].split(','))[1],10)
        #modificare quà per impostare di nuovo il reporting non merged(diversi descrittori)
        #num_modelli = 18
        # 1 perchè merged
        num_modelli = 1
        line_size = (line_size / num_classificatori) / num_modelli
        const_line_size = line_size
        final_iter = num_classificatori #* num_modelli
        
        tmp_model = None
        requestbody.append( [(rows[i].split(','))[0],"","","","","","","",""])
        while(j < final_iter):
          model = (rows[i].split(','))[0]

          #debug per capire se sto estraendo le colonne giuste 

          #print(rows[i+2].split(',')[0] + " " + rows[i].split(',')[0] + rows[i+7].split(',')[0] + (rows[i+8].split(','))[0]
          #      + rows[i+13].split(',')[0] + rows[i+17].split(',')[0] + (rows[i+22].split(','))[0]
          #+ (rows[i+24].split(','))[0] + (rows[i+25].split(','))[0]
          #      )
          classificatore = rows[i+2].split(',')[0]


          accuracy = (rows[i+7].split(','))[avg]
          precision = (rows[i+8].split(','))[avg]
          recall = (rows[i+13].split(','))[avg]
          specificity = (rows[i+17].split(','))[avg]
          fscore = (rows[i+22].split(','))[avg]
          MCC = (rows[i+24].split(','))[avg]
          BACC = (rows[i+25].split(','))[avg]
          requestbody.append(["",classificatore,accuracy,precision,recall,specificity,fscore,MCC,BACC])
          i += 28
          j += 1
          line_size += math.floor(const_line_size)
          tmp_model = (rows[i].split(','))[0]
          if(model != tmp_model):
            requestbody.append( [tmp_model,"","","","","","","",""])
        k += 1
    # request body è la tabella finale che andrà su drive
    body = {"values": requestbody}
    
    request = send_spreadsheet.values().append(spreadsheetId=f, range="A:I", valueInputOption="RAW", insertDataOption="INSERT_ROWS", body = body)
    response = request.execute()
    

def main(set):
    # listone di file su drive in cui mettere i report che arrivano da matlab    
    files = {
        "_Enhanced" : '',
        "_LocEntropy":'',
        "_LocStD" :   '',
        "_Original" : '' #,
    }
    
   
    files = [{       #merged - shuffle - set 4 excluded - feature selection
        "_Enhanced" : '',
        "_LocEntropy":'',
        "_LocStD" :   '',
        "_Original" : '' #,
        }]
    map = {
        4 : 0,
        5 : 1,
        6 : 2,
        9 : 3,
        10: 4,
        11: 5,
        12: 6,
        13: 7,
        14: 8,
        15: 9,
    }
    files = files[map[set]]
    #FILE = files.get(file)

    realpath = os.path.dirname(os.path.abspath(__file__))
    setnum = (reportfile.split(".")[0]).split("_")[-1]
    report_path = reportfile
    print(report_path)
    creds = None
    cycles = 0
    report_type = sendreport_v2
    # cicli per accedere API google
    while (not creds or not creds.valid) and cycles < 3:
        try:
            if os.path.exists('token.json'):
                creds = Credentials.from_authorized_user_file('token.json', SCOPES)
                # If there are no (valid) credentials available, let the user log in.
            if not creds or not creds.valid:
                if creds and creds.expired and creds.refresh_token:
                    try:
                            os.remove('token.json')
                    except:
                            pass
                    creds.refresh(Request())
                else:
                    flow = InstalledAppFlow.from_client_secrets_file(usercreds, SCOPES)
                    creds = flow.run_local_server(port=0)

            else:
                break
            with open('token.json', 'w') as token:
                    token.write(creds.to_json())
        except Exception as e:
            print(e)
        time.sleep(30)
        cycles += 1

    try:
        if not (not creds or not creds.valid):
            service = build('sheets', 'v4', credentials=creds)
            # Call the Sheets API
            sheet = service.spreadsheets()
            report = get_report(report_path)
            
            if report != None and report != "":
                report_type(report,sheet,f=FILE)
                #with open(report_path,"w") as report:
                # invio notifica appena finisce
                rq.get("http://lorevitcon.work/matlab/"+reportfile)
                #    pass
                
            else :
                raise Exception("File non trovato")
            
    except Exception as e:
        print(e)




# funzioni per creazione avgtable
def single_avg(tabelle,service):
    
    limit = 130
    try:
        tabelle_scaricate = [] 
        extracted_content = []
        finaltable = []
        for tabella in tabelle:
            result = service.files().export_media(fileId=tabella[1], mimeType='text/csv').execute()
            result = result.decode('utf-8').splitlines()[0:limit]
            extracted = []
            for string in result:
                try:
                    singlestring = string.split(",")

                    v = int(singlestring[11].replace('"',""),10)

                    res = [singlestring[0],singlestring[1],v if v > 0 else 100]
                    extracted.append(res)
                except:
                    res = [singlestring[0].replace("modello : ",""),singlestring[1],0]
                    extracted.append(res)
            #for e in extracted:
            #    print(e)
            extracted_content.append(extracted)
        i = 0
        len_avg = len(extracted_content)
        #print(extracted_content)
        while i < len(extracted_content[0]):
            j = 0
            avg = 0
            while j < len_avg:
                avg += extracted_content[j][i][2]
                j += 1
            z = 0
            avg = avg/(len_avg*100)
            while z < len_avg:
                calc = math.pow((extracted_content[z][i][2]/100 - avg),2)
                z+=1
            std = math.sqrt(1/len_avg*calc)
            
            finaltable.append([extracted_content[0][i][0],extracted_content[0][i][1],('%.2f' % round(avg, 2))+str("("+str('%.2f' % std)+")")])
            i += 1
        #for e in finaltable:
        #    print(e)
      
            
            

    except HttpError as error:
        # TODO(developer) - Handle errors from drive API.
        print(f"An error occurred: {error}")
    return finaltable
def send(table):


    
    requestbody = []
    line = []

    i = 1

    while i <len(table):
        val = table[i][0]
        if(val != ''):
            line.append(val)
        i+=1
    
    requestbody.append(line)
    j = 0
    
    while j < 6:
        i = 3 + j
        line = []
        line.append(table[i][1])
        while i < len(table):
            line.append(table[i][2])
            i += 7
        j += 1
        requestbody.append(line)
    
    return requestbody
        




def avg_report(service,folders,creds,sheetID):
    imgtype = ['Enhanced','LocEntropy','LocStD','Original']
    Files_per_filter = []
    for filter in imgtype:
        files_in_filter = []
        for folderID in folders:
            results = (
                service.files()
                .list(
                    q=f"'{folderID}' in parents and trashed = false and name contains '{filter}' and not fullText contains 'Score'",
                    fields="nextPageToken, files(id, name)",
                    supportsAllDrives=True, includeItemsFromAllDrives=True)
                .execute()
            )
            
            items = results.get("files", [])
            
            for item in items:
                print(item['name'])
                files_in_filter.append([item['name'],item['id']])
        Files_per_filter.append(files_in_filter)
    
    final_tables = []
    
    for j in Files_per_filter:
        final_tables.append(single_avg(j,service))
    a = []
    for j in final_tables:
        a.append(send(j))
    Files_per_filter = []
    for e in a:
        for i in e:
            Files_per_filter.append(i)
    service = build('sheets', 'v4', credentials=creds)
    # Call the Sheets API
    sheet = service.spreadsheets()
    body = {"values": Files_per_filter}
    request = sheet.values().append(spreadsheetId=sheetID, valueInputOption="RAW",range="A:Z", insertDataOption="INSERT_ROWS", body = body)
    response = request.execute()
    
    
    
            



# main per avgtable, l'id è l'id del file sheet dove mettere la avgtable
def main_v2(sheetID,fol_ID):
    # id della folder da dove estrarre i dati per calcolare la media
    folder_id = fol_ID
    creds = None
    cycles = 0
    SCOPES = ["https://www.googleapis.com/auth/drive",'https://www.googleapis.com/auth/spreadsheets']
    while (not creds or not creds.valid) and cycles < 3:
        try:
            if os.path.exists('token.json'):
                creds = Credentials.from_authorized_user_file('token.json', SCOPES)
                # If there are no (valid) credentials available, let the user log in.
            if not creds or not creds.valid:
                if creds and creds.expired and creds.refresh_token:
                    try:
                            os.remove('token.json')
                    except:
                            pass
                    creds.refresh(Request())
                else:
                    flow = InstalledAppFlow.from_client_secrets_file(usercreds, SCOPES)
                    creds = flow.run_local_server(port=0)

            else:
                break
            with open('token.json', 'w') as token:
                    token.write(creds.to_json())
        except Exception as e:
            print(e)
        time.sleep(30)
        cycles += 1

    try:
        if not (not creds or not creds.valid):
            service = build("drive", "v3", credentials=creds)
            results = (
                service.files()
                .list(
                    q=f"parents in '{folder_id}' and trashed = false",
                    fields="nextPageToken, files(id, name)")
                .execute()
            )
            items = results.get("files", [])

            if not items:
              print("No files found.")
              return
            folders = []
            for item in items:
                folders.append(item['id'])
            avg_report(service,folders,creds,sheetID)
    except HttpError as error:
        # TODO(developer) - Handle errors from drive API.
        print(f"An error occurred: {error}")

def local_main(set):
    rows = get_report(reportfile).splitlines()
    
    requestbody = []
    line_size = len(rows)
    avg = 3
    len_rows = line_size
    avg_type = { 3 : "macroavg",4 : "microavg",5:"weightedavg"}
    k = 3
    num_modelli = 18
    if(len_rows < 3020):
        num_modelli = 1
        # serve per il parsing della versione dei test in merge, 3020 sono il numero di righe della versione più grande(con solo 18)
    i = 0
    
    while(k < 6 and i < len_rows):
        avg = k
        line_size = len_rows
        requestbody.append( [avg_type[avg],"","","","","","","",""])
        requestbody.append([reportfile,"classificatore","accuracy","precision","recall","specificity","fscore","MCC","BACC"])
        i = 2
        j = 0
        num_classificatori = int((rows[1].split(','))[0],10)
        num_modelli = int((rows[1].split(','))[1],10)
        
        line_size = (line_size / num_classificatori) / num_modelli
        const_line_size = line_size
        final_iter = num_classificatori * num_modelli
        
        tmp_model = None
        requestbody.append( [(rows[i].split(','))[0],"","","","","","","",""])
        while(j < final_iter and i < len_rows - 28):
          model = (rows[i].split(','))[0]

          #debug per capire se sto estraendo le colonne giuste 

          #print(rows[i+2].split(',')[0] + " " + rows[i].split(',')[0] + rows[i+7].split(',')[0] + (rows[i+8].split(','))[0]
          #      + rows[i+13].split(',')[0] + rows[i+17].split(',')[0] + (rows[i+22].split(','))[0]
          #+ (rows[i+24].split(','))[0] + (rows[i+25].split(','))[0]
          #      )
          
          classificatore = rows[i+2].split(',')[0]
          

          accuracy = (rows[i+7].split(','))[avg]
          precision = (rows[i+8].split(','))[avg]
          recall = (rows[i+13].split(','))[avg]
          specificity = (rows[i+17].split(','))[avg]
          fscore = (rows[i+22].split(','))[avg]
          MCC = (rows[i+24].split(','))[avg]
          BACC = (rows[i+25].split(','))[avg]
          requestbody.append(["",classificatore,accuracy,precision,recall,specificity,fscore,MCC,BACC])
          i += 28
          j += 1
          line_size += math.floor(const_line_size)
          tmp_model = (rows[i].split(','))[0]
          if(model != tmp_model):
            requestbody.append( [tmp_model,"","","","","","","",""])
        k += 1
    with open(reportfile+"parsed.txt","w+") as towrite:
        for line in requestbody:
            for elem in line:
                towrite.write(" \""+str(elem)+" \""+" , ")
            towrite.write("\n")
    # request body è la tabella finale che andrà su drive

if __name__ == '__main__' :
    realpath = os.path.dirname(os.path.abspath(__file__))
    usercreds = realpath + '/usercreds.json'
    #creds = None

    #main_v2("")
    file =  str(sys.argv[1])
    reportfile = str(sys.argv[2])
    set = reportfile.split("_")[-1][0:2]
    reportfile = reportfile.split("/")[-1]
    set = int(''.join(filter(str.isdigit, set)),10)
    #main(4)
    local_main(set)
   