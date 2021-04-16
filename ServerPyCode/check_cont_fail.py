import numerapi
import requests
#"data.rounds.0.number"

seller = "integration_test_7"
buyer = "jefferythewind"
sellerStakePromise = 0

def checkContractFailure(seller, buyer, sellerStakePromise, startStamp):

    roundNum = requests.get("https://api-tournament.numer.ai/graphql?query={rounds{number}}").json()["data"]["rounds"][0]["number"]

    sellerStake = requests.get("https://api-tournament.numer.ai/graphql?query={v2UserProfile(username:\""+seller+"\"){totalStake}}").json()["data"]["v2UserProfile"]["totalStake"]
    sellerLatestRound = requests.get("https://api-tournament.numer.ai/graphql?query={userActivities(username:\""+seller+"\",tournament:8){roundNumber}}").json()["data"]["userActivities"][0]["roundNumber"]

    print("https://api-tournament.numer.ai/graphql?query={v2UserProfile(username:\""+buyer+"\"){dailySubmissionPerformances{roundNumber}}}")
    buyerLatestRound = requests.get("https://api-tournament.numer.ai/graphql?query={v2UserProfile(username:\""+buyer+"\"){dailySubmissionPerformances{roundNumber}}}").json()["data"]["v2UserProfile"][0]["roundNumber"]


    print("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:"+ str(buyerLatestRound) +",username:\""+ buyer +"\"){roundDailyPerformances{correlation}}}")
    buyerLatestCorrelation = requests.get("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:"+ str(buyerLatestRound) +",username:\""+ buyer +"\"){roundDailyPerformances{correlation}}}").json()["data"]["roundSubmissionPerformance"]["roundDailyPerformances"][0]["correlation"]
    sellerLatestCorrelation = requests.get("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:"+ str(sellerLatestRound) +",username:\""+ seller +"\"){roundDailyPerformances{correlation}}}").json()["data"]["roundSubmissionPerformance"]["roundDailyPerformances"][0]["correlation"]

    #("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:",SteakQuarterlyUtil.uintToStr(uint256(dataAPI[numeraiLatestRoundRequestId])),",username:\"",buyerModelName,"\"){roundDailyPerformances{payoutPending}}}")),
            #"data.roundSubmissionPerformance.roundDailyPerformances.0.payoutPending",10**18);

    buyerPayoutPending = requests.get("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:"+str(buyerLatestRound)+",username:\""+buyer+"\"){roundDailyPerformances{payoutPending}}}").json()["data"]["roundSubmissionPerformance"]["roundDailyPerformances"][0]["payoutPending"]
    sellerPayoutPending = requests.get("https://api-tournament.numer.ai/graphql?query={roundSubmissionPerformance(roundNumber:"+str(sellerLatestRound)+",username:\""+seller+"\"){roundDailyPerformances{payoutPending}}}").json()["data"]["roundSubmissionPerformance"]["roundDailyPerformances"][0]["payoutPending"]

    if(buyerLatestCorrelation != sellerLatestCorrelation):
        return "Submissions rounds not identical\nBUYER:" + str(buyerLatestRound) + "\nSELLER:"+str(sellerLatestRound)

    if(buyerLatestCorrelation != sellerLatestCorrelation):
        return "Submissions not identical\nBUYER:" + str(buyerLatestCorrelation) + "\nSELLER:"+str(sellerLatestCorrelation)



    print("ROUND NUMBER",roundNum)
    print("SELLER STAKE", sellerStake)
    print("SELLER LATEST RND", sellerLatestRound)
    print("BUYER LATEST RND", buyerLatestRound)

    print("BUYER LATEST CORR ",buyerLatestCorrelation)
    print("SELLER LATEST CORR ",sellerLatestCorrelation)

    print("BUYER PAYOUT PENDING",buyerPayoutPending)

    print("SELLER PAYOUT PENDING",sellerPayoutPending)

print(checkContractFailure(seller,buyer,sellerStakePromise,0))
