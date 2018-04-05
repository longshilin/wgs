import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;

/*
    编写比对的mapper类
 */
public class comparisonReducer extends Reducer<Text, Text, Text, Text> {

    private static String LOG_DIRECTORY = "./wgs-logs";
    private static String SCRIPT_DIRECTORY = "./wgs-scripts";

    @Override
    protected void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {

        HashMap<String, String> templateMap = new HashMap<>();
        Iterator<Text> value = values.iterator();
        int count = 0;
        String str = "";
        while (value.hasNext()) {
            str = value.next().toString();
            templateMap.put("sample_name" + (++count), str);
            System.out.println("sample_name" + count + "-----" + str);
        }
        mergeGVCF(templateMap);
        context.write(new Text("1"), new Text(str));
    }

    private static void mergeGVCF(HashMap<String, String> templateMap) {


        String template = "comparisonReducer.template";
        String scriptPath = SCRIPT_DIRECTORY + "/comparison_reducer_" + ".sh";
        String logPath = LOG_DIRECTORY + "/comparison_reducer_" + ".log";

        // 从模板创建具体脚本
        File scriptFile = TemplateEngine.createDynamicContentAsFile(template, templateMap, scriptPath);

        if (scriptFile != null) {
            ShellScriptUtil.callProcess(scriptPath, logPath);
        }
    }
}
