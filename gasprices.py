import requests
import matplotlib.pyplot as plt
import time
seconds_per_day = 86400
gwei = 1000000000
prices = []
time_estimates = []
for i in range(1,101):
    print(i)
    prices.append(gwei * i)
    time_estimates.append(float(requests.get("https://api.etherscan.io/api?module=gastracker&action=gasestimate&gasprice=2000000000&apikey=VRY48ZXPBVJZDAW276IB937P338GD4IQXS").json()["result"])/seconds_per_day)
    if(i % 4 == 0):time.sleep(1)
plt.plot(prices,time_estimates)
plt.show()
print(requests.get("https://api.etherscan.io/api?module=gastracker&action=gasestimate&gasprice=2000000000&apikey=VRY48ZXPBVJZDAW276IB937P338GD4IQXS").json())