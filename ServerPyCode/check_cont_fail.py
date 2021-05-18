import requests
#"data.rounds.0.number"
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import time


def check_line(lin):
    saved_user_string = lin.split(",")
    if(len(saved_user_string) == 5):
        #print(requests.get("https://api-tournament.numer.ai/graphql?query={rounds{number}}").json())
        if(time.gmtime() > int(saved_user_string[3]))
        roundNum = requests.get("https://api-tournament.numer.ai/graphql?query={rounds{number}}").json()["data"]["rounds"][0]["number"]
        controlBuyer = None
        try:
            controlBuyer = requests.get("https://api-tournament.numer.ai/?query={v2UserProfile(username:\""+ saved_user_string[1] +"\"){control}}").json()["data"]["v2UserProfile"]["control"]
        except:
            pass
        controlSeller = None
        try:
            controlSeller = requests.get("https://api-tournament.numer.ai/?query={v2UserProfile(username:\""+ saved_user_string[0] +"\"){control}}").json()["data"]["v2UserProfile"]["control"]
        except:
            pass
        sellerStake = 0.0
        try:
            sellerStake = requests.get("https://api-tournament.numer.ai/graphql?query={v2UserProfile(username:\""+saved_user_string[0]+"\"){totalStake}}").json()["data"]["v2UserProfile"]["totalStake"]
        except:
            pass

        if(controlBuyer is None or controlSeller is None or float(sellerStake) < float(saved_user_string[2])):
            return "It appears the models " + saved_user_string[0] + " and " + saved_user_string[1] + " were not submitted on time or at all, or the seller did not stake as much as they promised to. You should confirm this on numer.ai and request a contract closure if this was unintended."
        else:
            sellerCorr = requests.get("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:"+str(roundNum)+",username:\""+saved_user_string[0]+"\"){roundDailyPerformances{correlation}}}").json()["data"]["roundSubmissionPerformance"]["roundDailyPerformances"][-1]["correlation"]
            buyerCorr = requests.get("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:"+str(roundNum)+",username:\""+saved_user_string[1]+"\"){roundDailyPerformances{correlation}}}").json()["data"]["roundSubmissionPerformance"]["roundDailyPerformances"][-1]["correlation"]
            if(buyerCorr != sellerCorr):
                return "It appears the correlations of models " + saved_user_string[0] + " and " + saved_user_string[1] + " do not match. You should confirm this on numer.ai and request a contract closure if this was unintended."
    return ""

def send_warning(ema,msg):
        #The mail addresses and password
        
        mail_content = msg
        sender_address = "bogachup1234@gmail.com"
        sender_pass = 'xxx'
        receiver_address = ema
        #Setup the MIME
        message = MIMEMultipart()
        message['From'] = sender_address
        message['To'] = receiver_address
        message['Subject'] = 'Steak Contract Failure Warning.\n'    #The subject line
        #The body and the attachments for the mail
        message.attach(MIMEText(mail_content, 'plain'))
        #Create SMTP session for sending the mail
        session = smtplib.SMTP('smtp.gmail.com', 587) #use gmail with port
        session.starttls() #enable security
        session.login(sender_address, sender_pass) #login with mail_id and password
        text = message.as_string()
        session.sendmail(sender_address, receiver_address, text)
        session.quit()
        print('Mail Sent')



    #print(roundNum,controlBuyer,controlSeller,sellerStake,sellerCorr,buyerCorr)
#check_line("bensch_c,bensch_a,1.31232,9932.213,testmay2@gmail.com")

text_file = open("emails.txt", "r")
 
#read whole file to a string
emails = text_file.read()
 
#close file
text_file.close()

for lne in emails.split("\n"):
    check = check_line(lne)
    if(len(check) > 0):
        send_warning(lne.split(",")[-1],check)
 

