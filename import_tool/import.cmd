set project="KAVKIS Platform"
set db="win_based_projects_endpoint8_w"
java -Xms512m -Xmx512m -jar ./import_testcase.jar testcase.xml import qc http://******:8080/tfs %project% kl kalistratov **** server.avp.ru %db% 20627
