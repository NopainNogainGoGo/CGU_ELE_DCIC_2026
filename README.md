## 目錄

```text
├── LAB1/                     
├── LAB2/                     
├── LAB3/             
├── LAB4/                  
├── LAB5/              
├── Project/                 
└── Lectures/                  # 課程講義
    ├── 2026_0225_Lecture_01_FT and Random Process...
    ├── 2026_0304_Lecture_02_MCS and Optimal Detec...
    ├── 2026_0318_Lecture_03_Channel Model-X.pdf
    ├── 2026_0401_Lecture_04_Channel Coding-X.pdf
    ├── 2026_0408_Lecture_05_Scambler.pdf
    ├── 2026_0422_Lecture_06_AGC_Pulse_Shaping_Rx...
    ├── 2026_0506_Lecture_07_Equalization-X.pdf
    └── channel_encoding.pdf

```

## Lectures

| 講義名稱 | 主題  |
| --- | --- |
| **Lecture 01** | 傅立葉轉換 (Fourier Transform, FT) 與隨機程序 (Random Process) |
| **Lecture 02** | 調變編碼方案 (MCS) 與最佳偵測 (Optimal Detection) |
| **Lecture 03** | 通道模型 (Channel Model) |
| **Lecture 04** | 通道編碼 (Channel Coding) |
| **Lecture 05** | 擾碼器 (Scrambler) |
| **Lecture 06** | 自動增益控制 (AGC)、脈衝修整 (Pulse Shaping) 與接收端 (Rx) 設計 |
| **Lecture 07** | 通道等化器 (Equalization) |
| **補充資料** | 通道編碼 (`channel_encoding.pdf`) |

---

## Laboratories

* **LAB 1**：[Mapper Design for PAM-2 and 16-QAM]
* **LAB 2**：[Simpler Transceiver Design for PAM-2 and 16-QAM ]
* **LAB 3**：[Convolutional Encoder and Trellis Decoder ]
* **LAB 4**：[Self-Synchronization Scrambler/Descrambler]
* **LAB 5**：[AGC Design for 16-QAM ]

---

## Project

* **名稱**：[ML Sequence Estimation using Viterbi]
* **簡介**：
使用 Viterbi 演算法，對經過 ISI 通道的 QPSK 訊號進行解碼。
通道模型為 `y(k) = x(k) + 0.3·x(k-1) + 0.7·x(k-2)`，接收端觀測到 12 個帶有雜訊的複數訊號，目標是還原出原始傳送的符號序列。
Viterbi 演算法將問題轉化為尋找最短路徑。狀態由前兩個輸入符號決定，共 16 種組合。演算法逐步計算每條路徑的累積誤差，並在每個時刻只保留各狀態的最佳路徑，最後從終點回溯還原出最佳序列。
為了確認結果正確，我窮舉所有約 100 萬種可能的符號組合。兩者得到相同的最小誤差。
```
