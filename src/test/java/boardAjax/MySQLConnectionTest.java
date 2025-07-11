package boardAjax;

import java.sql.Connection;
import java.sql.DriverManager;

import org.junit.Test;

public class MySQLConnectionTest {

	private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String URL = "jdbc:mysql://127.0.0.1:3306/egov_test?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Seoul";
    private static final String USER = "jeongmargot";
    private static final String PW = "jeongmargot130";
    
    @Test
    public void testConnection() throws Exception {
    	Class.forName(DRIVER);
    	
    	try(Connection conn = DriverManager.getConnection(URL, USER, PW)) {
    		System.out.println("connection info: " + conn);
    	
    	} catch(Exception e) {
    		e.printStackTrace();
    	}
    }
}
