import java.io.File;

/**
 * shell脚本工具包
 */
public class ShellScriptUtil {

    /**
     * 调用Shell脚本执行的方法
     * @param paths 指定多个路径参数
     *              <ul><li>其中第一个指定的是shell模版</li>
     *              <li>第二个参数指定的是脚本执行结果存放路径</li>
     *              <li>第三个参数指定的是执行脚本中日志存放路径，是可选参数，未给出此参数则默认为无日志输出</li></ul>
     */
    public static void callProcess(String... paths) {
        File outputFile;
        File logFile;
        Process process;

        String scriptPath = paths[0];
        String chmod = "chmod u+x " + scriptPath;
        try {
            // 为shell脚本增加可执行权限
            Runtime.getRuntime().exec(chmod).waitFor();
        } catch (Exception e) {
            e.printStackTrace();
        }

        System.out.println(scriptPath);
        ProcessBuilder pb = new ProcessBuilder("./" + scriptPath);
        pb.inheritIO();

        // 指定shell脚本执行的结果输出路径和执行时日志文件的输出路径
        if (paths.length == 3) {
            outputFile = new File(paths[1]);
            pb.redirectOutput(outputFile);
            logFile = new File(paths[2]);
            pb.redirectError(logFile);
        }
        // 指定shell脚本执行的结果输出路径
        if (paths.length == 2) {
            logFile = new File(paths[1]);
            if(logFile.exists())
                logFile.delete();
            pb.redirectError(logFile);
        }
        try {
            process = pb.start();
            process.waitFor();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
