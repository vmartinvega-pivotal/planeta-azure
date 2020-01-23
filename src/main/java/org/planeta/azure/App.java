package org.planeta.azure;

import java.sql.Connection;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.DriverManager;

public class App {
	
	private static final String AZURE = "azure";
	private static final String POSTGRES = "postgres";

    public static void main(String[] args) {

    	String hostName = args[0];
    	String dbName = args[1];
    	String user = args[2];
    	String password = args[3];
        String selectSql = args[4];
        String driver = args[5];
        String port = args[6];
        
        String url = null;
        if (driver.toLowerCase().equals(AZURE)) {
        	url = String.format("jdbc:sqlserver://%s:1433;database=%s;user=%s;password=%s;encrypt=true;"
                    + "hostNameInCertificate=*.database.windows.net;loginTimeout=30;", hostName, dbName, user, password);
        }else if (driver.toLowerCase().equals(POSTGRES)) {
        	url = String.format("jdbc:postgresql://%s:%s/%s", hostName, port, dbName);
        }

        Connection connection = null;

        try {
            connection = DriverManager.getConnection(url);

            try (Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery(selectSql)) {
            	String output;
            	String columnValue = "";
            	SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            	ResultSetMetaData rsmd = resultSet.getMetaData();
    			int numberOfColumns = rsmd.getColumnCount();
            	
                while (resultSet.next()){
                	output="";
    				// Get the column names; column indices start from 1
    				for (int i=1; i< numberOfColumns+1; i++){
    					//Extra try/catch block because of an Oracle problem at Virgin Airlines.  
    					//Getting an "ArrayIndexOutOfBoundsException" error which might be caused by the Oracle JDBC driver
    					try{
    				      		columnValue = resultSet.getString(i);
    					}
    					catch (Exception e){
    						columnValue = (String) resultSet.getObject(i);
    					}
    					
    					//Oracle has the DATE data type (SQL Server has date and datetime)
						//The range for Oracle DATE is January 1, 4712 BCE through December 31, 4712 CE 
						if (rsmd.getColumnTypeName(i) == "DATE" || rsmd.getColumnTypeName(i) == "TIMESTAMP" ){
							columnValue = df.format(resultSet.getTimestamp(i));
						}

    					if (columnValue != null){
    						//Filter out \ and | from the columnValue for not null records.  the rest will default to "null"
    						columnValue = columnValue.replace("\\", "\\\\");
    						columnValue = columnValue.replace("|", "\\|");
    						columnValue = columnValue.replace("\r", " ");
    						columnValue = columnValue.replace("\n", " ");
    						columnValue = columnValue.replace("\0", "");
    					}

    					if (i == 1) {
    						output = columnValue;
    					}
    					else {
    						output = output + "|" + columnValue;
    					}
    				}

    				System.out.println(output);
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }finally {
        	if (connection != null) {
        		try {
					connection.close();
				} catch (SQLException e) {
				}
        	}
        }
    }
}
