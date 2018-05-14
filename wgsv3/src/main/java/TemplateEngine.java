import freemarker.template.Configuration;
import freemarker.template.DefaultObjectWrapper;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import org.apache.log4j.Logger;

import java.io.*;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * 这个类使用FreeMarker(http://freemarker.apache.org) FreeMarker是一个模板引擎，这是一个根据模板生成文本输出的通用工具
 * (从shell脚本到自动生成的源代码都是文本输出)
 */
public class TemplateEngine {

    // 日志记录
    private static Logger theLogger = Logger.getLogger(TemplateEngine.class.getName());

    // 通常在整个应用生命周期中只执行一次
    private static Configuration TEMPLATE_CONFIGURATION = null;
    private static AtomicBoolean initialized = new AtomicBoolean(false);

    // freemarker templates 存放目录
    protected static String TEMPLATE_DIRECTORY = "/home/elon/IdeaProjects/wgs/wgsv3/wgs-templates";

    public static void init() throws Exception {
        if (initialized.get()) {
            return;
        }
        initConfiguration();
        initialized.compareAndSet(false, true);
    }

    static {
        if (!initialized.get()) {
            try {
                init();
            } catch (Exception e) {
                theLogger.error("在初始化阶段，模版引擎初始化错误...", e);
            }
        }
    }

    // 初始化配置
    private static void initConfiguration() throws Exception {
        TEMPLATE_CONFIGURATION = new Configuration();
        TEMPLATE_CONFIGURATION.setDirectoryForTemplateLoading(new File(TEMPLATE_DIRECTORY));
        TEMPLATE_CONFIGURATION.setObjectWrapper(new DefaultObjectWrapper());
        TEMPLATE_CONFIGURATION.setWhitespaceStripping(true);
        TEMPLATE_CONFIGURATION.setClassicCompatible(true);
    }

    /**
     * 通过模板和keyValuePairs动态创建shell脚本
     *
     * @param templateFileName 一个模板文件名，如：script.sh.template，其模板目录已在configuration中指定
     * @param keyValuePairs 存储数据模型的<K,V>Map
     * @param outputScriptFilePath 生成的脚本文件路径
     * @return 一个可执行的Shell脚本文件
     */
    public static File createDynamicContentAsFile(String templateFileName,
        Map<String, String> keyValuePairs, String outputScriptFilePath) {
        if ((templateFileName == null) || (templateFileName.length() == 0)) {
            return null;
        }

        Writer writer = null;
        File outputFile = null;
        try {
            Template template = TEMPLATE_CONFIGURATION.getTemplate(templateFileName);
            // 合并数据模型和模板，生成shell脚本
            outputFile = new File(outputScriptFilePath);
            writer = new BufferedWriter(new FileWriter(outputFile));
            template.process(keyValuePairs, writer);
            writer.flush();
        } catch (IOException e) {
            theLogger.error("创建文件失败...", e);
        } catch (TemplateException e) {
            theLogger.error("freeMarker动态创建shell脚本失败...", e);
        } finally {
            if (writer != null) {
                try {
                    writer.close();
                } catch (IOException e) {
                    theLogger.error("创建shell脚本，写入文件时出现IO异常...");
                }
            }
        }
        return outputFile;
    }
}
