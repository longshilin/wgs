import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;

/*
    编写全基因组测序的Reducer类，主要完成对每个样本组的变异检测文件的合并操作
 */
public class wgsReducer extends Reducer<Text, Text, Text, Text> {

    // 定义日志存放的目录
    private static String LOG_DIRECTORY = "/home/elon/IdeaProjects/wgs/wgsv3/wgs-logs";
    // 定义shell脚本存放的目录
    private static String SCRIPT_DIRECTORY = "/home/elon/IdeaProjects/wgs/wgsv3/wgs-scripts";

    @Override
    protected void reduce(Text key, Iterable<Text> values, Context context)
        throws IOException, InterruptedException {

        HashMap<String, String> templateMap = new HashMap<>();
        Iterator<Text> value = values.iterator();
        int count = 0;
        String str = "";
        while (value.hasNext()) {
            str = value.next().toString();
            templateMap.put("sample_name" + (++count), str);
        }
        mergeGVCF(templateMap);
        context.write(new Text("1"), new Text(str));
    }

    /**
     * 对每个样本组生成的变异检测数据合并到一个总的变异检测文件，完成全基因组的检测
     *
     * @param templateMap 每个样本组的变异检测数据的存储信息
     */
    private static void mergeGVCF(HashMap<String, String> templateMap) {

        String template = "wgsReducer.template";
        String scriptPath = SCRIPT_DIRECTORY + "/wgs_reducer_" + ".sh";
        String logPath = LOG_DIRECTORY + "/wgs_reducer_" + ".log";

        // 从模板创建具体脚本
        File scriptFile = TemplateEngine
            .createDynamicContentAsFile(template, templateMap, scriptPath);
        // 调用执行脚本的工具方法，执行上一步生成的脚本文件
        if (scriptFile != null) {
            ShellScriptUtil.callProcess(scriptPath, logPath);
        }
    }
}
