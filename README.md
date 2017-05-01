# 台灣證交所 - 個股日成交資訊(https://goo.gl/SyUJFi)

測試環境 ubuntu 14.04
1. 使用R web api取得資料步驟:
1.1 安裝getstock套件(api資料夾) - getstock_0.1.0.tar.gz。
1.2 用Terminal執行opencpu.R，啟動opencpu api server。
防止port被佔用(lsof -t -i :12345 | xargs kill)
1.3 執行test_script.R測試API是否可正常運作。

2. 使用getStock.R取得資料
2.1 Termimal版本 - 在Terminal下參數執行，後續可用crontab做定期排程。
2.2 Script版本 - 在R介面中執行且無參數設定，必須一開始hardcore在程式碼裡，所以彈性程度低。
