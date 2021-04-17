import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


def send_mail(user):
    #The mail addresses and password
    
    mail_content = """Hello,
This is a simple mail. There is only text, no attachments are there The mail is sent using Python SMTP library.
Thank You
"""+ user[0] + "   " + user[1]+ "   " + user[2] + "   "+ user[3]
    sender_address = "bogachup1234@gmail.com"
    sender_pass = 'xxx'
    receiver_address = user[4]
    print(user)
    #Setup the MIME
    message = MIMEMultipart()
    message['From'] = sender_address
    message['To'] = receiver_address
    message['Subject'] = 'A test mail sent by Python. It has an attachment.\n'    #The subject line
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
email_file = open("emails.txt","r")
users = email_file.read().split("\n")
for user in users:
    usr = user.split(",")
    if len(usr) != 5:
        continue
    send_mail(usr)
