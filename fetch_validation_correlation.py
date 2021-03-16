#bensch 3/15/2021
#Retreive a CSV of the validation correlation for the latest round
import numerapi
import requests



def run_query(uri, query, statusCode, headers):
    request = requests.post(uri, json={'query': query}, headers=headers)
    return request.json()


napi = numerapi.NumerAPI()

f = open("leaderboard.csv","w")
f.write("rank, username, valCorr\n")

leader_board = napi.get_leaderboard(2000)
i = 1
for usr in leader_board:
    queryT = """
{

userActivities(username:"""
    queryT += "\"" + usr["username"]+"\""
    queryT +=""",tournament:8){
  submission {
	validationCorrelation

  }
} 
}
"""
    print(i)
    #[0] to get the latest round
    f.write(str(i)+","+usr["username"]+","+str(run_query("https://api-tournament.numer.ai/",queryT,0,None)["data"]["userActivities"][0]["submission"]["validationCorrelation"])+"\n")
    i+=1
f.close()
