# 基于Hadoop的基因组测序大数据分析平台研究 
(WGS Sequencing In Hadoop MapReduce)

>声明：**基于Hadoop的基因组测序大数据分析平台研究**是本人2018年的毕业设计课题，根据网络资源和自己的专业知识，独立完成整个流程设计、平台搭建和单元测试等工作。**本系列文章是对该项目的一个整理总结和分享记录。该目录提及的系列文章可供转载，并无需通知作者，但需要在明显地方标注文章出处**


> 
> 开发环境介绍：通过个人便携式笔记本ThinkPad开发，内存是8GB。
> 
> + 操作系统：Ubuntu16
> + 开发平台：IDEA
> + 开发时间：2018年2月~5月



【目录】

<a href="https://blog.csdn.net/Coder__CS/article/details/81259481">  摘要</a>


<a href="https://blog.csdn.net/Coder__CS/article/details/80877018">1 绪论</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/80877018#11-论文的研究背景及意义">1.1 论文的研究背景及意义</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/80877018#12-国内外研究现状">1.2 国内外研究现状</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/80877018#13-论文的主要研究内容">1.3 论文的主要研究内容</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/80877018#14-章节安排">1.4 章节安排</a>

<a href="https://blog.csdn.net/Coder__CS/article/details/81256333#2-相关技术及原理">2 相关技术及原理</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81256333#21-hadoop相关技术和原理">2.1 Hadoop相关技术和原理</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81256333#22-全基因组测序相关技术和处理流程">2.2 全基因组测序相关技术和处理流程</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81256333#23-本章小结">2.3 本章小结</a>

<a href="https://blog.csdn.net/Coder__CS/article/details/81258544#3-基于hadoop基因测序数据处理关键技术的研究">3 基于Hadoop基因测序数据处理关键技术的研究</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81258544#31-测序处理流程与mapreduce结合">3.1 测序处理流程与MapReduce结合</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81258544#32-不同格式数据的访问与存储">3.2 不同格式数据的访问与存储</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81258544#33-分析流程的完整性">3.3 分析流程的完整性</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81258544#34-freemarker引擎与测序流程的模版化">3.4 FreeMarker引擎与测序流程的模版化</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81258544#35-本章小结">3.5 本章小结</a>

<a href="https://blog.csdn.net/Coder__CS/article/details/81258967#4-基于hadoop的平台搭建与mapreduce作业设计">4 基于Hadoop的平台搭建与MapReduce作业设计</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81258967#41-基于hadoop的伪分布式平台搭建">4.1 基于Hadoop的伪分布式平台搭建</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81258967#42-伪分布式环境的mapreduce作业构建">4.2 伪分布式环境的MapReduce作业构建</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81258967#43-基于hadoop分布式环境搭建">4.3 基于Hadoop分布式环境搭建</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81258967#44-分布式环境下mapreduce作业构建">4.4 分布式环境下MapReduce作业构建</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81258967#45-shell脚本执行引擎的构建">4.5 Shell脚本执行引擎的构建</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81258967#46-mapreduce作业编写与整体调度">4.6 MapReduce作业编写与整体调度</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81258967#47-本章小结">4.7 本章小结</a

<a href="https://blog.csdn.net/Coder__CS/article/details/81259348#5-系统的测试与扩展">5 系统的测试与扩展</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81259348#51-mrunit测试类编写">5.1 MRUnit测试类编写</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81259348#52-hadoop测序平台的测试">5.2 Hadoop测序平台的测试</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81259348#53-测序平台的分析与优化">5.3 测序平台的分析与优化</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81259348#54-基于hadoop基因测序平台的扩展">5.4 基于Hadoop基因测序平台的扩展</a>
- <a href="https://blog.csdn.net/Coder__CS/article/details/81259348#55-本章小结">5.5 本章小结</a>

<a href="https://blog.csdn.net/Coder__CS/article/details/81259398">结  论</a>
  
  
<a href="https://blog.csdn.net/Coder__CS/article/details/81259425">致  谢</a>
  

<a href="https://blog.csdn.net/Coder__CS/article/details/81259445">参 考 文 献</a>
 
