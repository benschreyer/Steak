

#python file to check a contract for violations locally, just add the model names and stake promise by the seller and run after Thursday scores are released
import requests
#"data.rounds.0.number"
import time

stake_promise = 1 #units of NMR
seller_model_name = "MODEL NAME OF SELLER HERE"
buyer_model_name = "MODEL NAME OF BUYER HERE"

def check_contract():
      #print(requests.get("https://api-tournament.numer.ai/graphql?query={rounds{number}}").json())


      roundNum = requests.get("https://api-tournament.numer.ai/graphql?query={rounds{number}}").json()["data"]["rounds"][0]["number"]
      controlBuyer = None
      try:
          controlBuyer = requests.get("https://api-tournament.numer.ai/?query={v2UserProfile(username:\""+ buyer_model_name +"\"){control}}").json()["data"]["v2UserProfile"]["control"]
      except:
          pass
      controlSeller = None
      try:
          controlSeller = requests.get("https://api-tournament.numer.ai/?query={v2UserProfile(username:\""+ seller_model_name +"\"){control}}").json()["data"]["v2UserProfile"]["control"]
      except:
          pass
      sellerStake = 0.0
      try:
          sellerStake = requests.get("https://api-tournament.numer.ai/graphql?query={v2UserProfile(username:\""+ seller_model_name+"\"){totalStake}}").json()["data"]["v2UserProfile"]["totalStake"]
      except:
          pass

      if(controlBuyer is None or controlSeller is None or float(sellerStake) < float(stake_promise)):
          return "It appears the models " + buyer_model_name+ " and " + seller_model_name + " were not submitted on time or at all, or the seller did not stake as much as they promised to. You should confirm this on numer.ai and request a contract closure if this was unintended."
      else:
          sellerCorr = requests.get("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:"+str(roundNum)+",username:\""+seller_model_name+"\"){roundDailyPerformances{correlation}}}").json()["data"]["roundSubmissionPerformance"]["roundDailyPerformances"][-1]["correlation"]
          buyerCorr = requests.get("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:"+str(roundNum)+",username:\""+buyer_model_name+"\"){roundDailyPerformances{correlation}}}").json()["data"]["roundSubmissionPerformance"]["roundDailyPerformances"][-1]["correlation"]
          if(buyerCorr != sellerCorr):
              return "It appears the correlations of models " + seller_model_name + " and " + buyer_model_name + " do not match. You should confirm this on numer.ai and request a contract closure if this was unintended."
  return ""
print(check_contract())
