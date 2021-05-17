import requests
#"data.rounds.0.number"



def check_line(lin):
    saved_user_string = lin.split(",")
    if(len(saved_user_string) == 5):
        #print(requests.get("https://api-tournament.numer.ai/graphql?query={rounds{number}}").json())
        roundNum = requests.get("https://api-tournament.numer.ai/graphql?query={rounds{number}}").json()["data"]["rounds"][0]["number"] - 1
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
            print("CONTRACT WAS NOT HONORED, MODELS LATE/UNSUBMITTED OR SELLER DID NOT STAKE AS MUCH AS THEY PROMISED")
        else:
            sellerCorr = requests.get("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:"+str(roundNum)+",username:\""+saved_user_string[0]+"\"){roundDailyPerformances{correlation}}}").json()["data"]["roundSubmissionPerformance"]["roundDailyPerformances"][-1]["correlation"]
            buyerCorr = requests.get("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:"+str(roundNum)+",username:\""+saved_user_string[1]+"\"){roundDailyPerformances{correlation}}}").json()["data"]["roundSubmissionPerformance"]["roundDailyPerformances"][-1]["correlation"]
            if(buyerCorr != sellerCorr):
                print("CORRELATIONS DONT MATCH CONTRACT NOT HONORED")
    #print(roundNum,controlBuyer,controlSeller,sellerStake,sellerCorr,buyerCorr)
check_line("bensch_c,bensch_a,1.31232,9932.213,testmay2@gmail.com")
