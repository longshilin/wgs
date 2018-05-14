import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;

/*
    编写全基因组测序的Mapper类，主要完成每个样本组的基因组测序分析的流程
 */
public class wgsMapper extends Mapper<LongWritable, Text, Text, Text> {

    // 定义日志存放的目录
    private static String LOG_DIRECTORY = "/home/elon/IdeaProjects/wgs/wgsv3/wgs-logs";
    // 定义shell脚本存放的目录
    private static String SCRIPT_DIRECTORY = "/home/elon/IdeaProjects/wgs/wgsv3/wgs-scripts";

    @Override
    protected void map(LongWritable key, Text value, Context context)
        throws IOException, InterruptedException {

        String sample_name = value.toString();
        wgs(sample_name);
        context.write(new Text("1"), new Text(sample_name));
    }

    /**
     * 根据传入的样本文件信息来并行化执行shell脚本,完成每个样本组数据的基因测序操作
     *
     * @param sampleName 单个的样本数据的存储信息串
     */
    private static void wgs(String sampleName) {
        HashMap<String, String> templateMap = new HashMap<>();
        templateMap.put("sample_name", sampleName);

        String template = "wgsMapper.template";
        String scriptPath =
            SCRIPT_DIRECTORY + "/wgs_mapper_" + templateMap.get("sample_name") + ".sh";
        String logPath = LOG_DIRECTORY + "/wgs_mapper_" + templateMap.get("sample_name") + ".log";

        // 从模板创建具体脚本
        File scriptFile = TemplateEngine
            .createDynamicContentAsFile(template, templateMap, scriptPath);
        // 调用执行脚本的工具方法，执行上一步生成的脚本文件
        if (scriptFile != null) {
            ShellScriptUtil.callProcess(scriptPath, logPath);
        }
    }
}
