% questa funzione serve per avviare il reporting automatico su google 
% drive utilizzando python
function [] = sendreport(stats,reportfile,pythonpath,setkey)


% creazione tabella 
writetable(stats,reportfile);
try
    % avvio report.py per parsing della tabella e invio su drive
    system("python " + pythonpath + " " + setkey + " " + reportfile);
catch
    warning("report non inviato");
end
end