package com.ps.e2e.jacoco.testcoverageexample;

import javax.management.MBeanServerConnection;
import javax.management.MBeanServerInvocationHandler;
import javax.management.ObjectName;
import javax.management.remote.JMXConnector;
import javax.management.remote.JMXConnectorFactory;
import javax.management.remote.JMXServiceURL;
import java.io.FileOutputStream;

public class MBeanClient {
    private static final String DESTFILE = "./target/jacoco-server.exec";

    private static final String SERVICE_URL = "service:jmx:rmi:///jndi/rmi://localhost:5000/jmxrmi";

    /**
     * Execute the example.
     *
     * @param args
     * @throws Exception
     */
    public static void main(final String[] args) throws Exception {
        // Open connection to the coverage agent:
        final JMXServiceURL url = new JMXServiceURL(SERVICE_URL);
        final JMXConnector jmxc = JMXConnectorFactory.connect(url, null);
        final MBeanServerConnection connection = jmxc
                .getMBeanServerConnection();

        final IProxy proxy = (IProxy) MBeanServerInvocationHandler
                .newProxyInstance(connection, new ObjectName(
                        "org.jacoco:type=Runtime"), IProxy.class, false);

        // Retrieve JaCoCo version and session id:
        System.out.println("Version: " + proxy.getVersion());
        System.out.println("Session: " + proxy.getSessionId());

        // Retrieve dump and write to file:
        final byte[] data = proxy.getExecutionData(false);
        final FileOutputStream localFile = new FileOutputStream(DESTFILE);
        localFile.write(data);
        localFile.close();

        // Close connection:
        jmxc.close();
    }

    public interface IProxy {
        String getVersion();

        String getSessionId();

        void setSessionId(String id);

        byte[] getExecutionData(boolean reset);

        void dump(boolean reset);

        void reset();
    }

    private MBeanClient() {
    }
}
