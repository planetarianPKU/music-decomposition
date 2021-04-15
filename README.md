# music-decomposition
music decomposition by matlab

该程序拾取音乐的频率，并生成时频的变化视频。

测试音乐为《一闪一闪亮晶晶》

程序设计上可识别四道线性频率，即主旋律和三和弦，可以自己调识别几道。

使用matlab信号处理功能工具箱的时频分析spectrogram和线性频率成分追踪tfridge两个函数实现。

音符按十二平均律定义，即以49号A音440Hz为基准，其他音符频率按照440*2^((n-49)/12)Hz推算。
