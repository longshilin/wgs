import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;

/*
    编写比对的mapper类
 */
public class comparisonMapper extends Mapper<LongWritable, Text, Text, Text> {

    private static String LOG_DIRECTORY = "./wgs-logs";
    private static String SCRIPT_DIRECTORY = "./wgs-scripts";

    @Override
    protected void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {

        String sample_name = value.toString();
        comparison(sample_name);
        context.write(new Text("1"),new Text(sample_name));


    }


    private static void comparison(String sampleName) {

        HashMap<String, String> templateMap = new HashMap<>();
        templateMap.put("sample_name", sampleName);

        String template = "comparisonMapper.template";
        String scriptPath = SCRIPT_DIRECTORY + "/comparison_mapper_" + templateMap.get("sample_name") + ".sh";
        String logPath = LOG_DIRECTORY + "/comparison_mapper_" + templateMap.get("sample_name") + ".log";

        // 从模板创建具体脚本
        File scriptFile = TemplateEngine.createDynamicContentAsFile(template, templateMap, scriptPath);

        if (scriptFile != null) {
            ShellScriptUtil.callProcess(scriptPath, logPath);
        }


    }

}
