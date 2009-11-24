@ECHO OFF

IF "%1" == "" (
  SET TIMES=1
) ELSE (
  SET TIMES=%1
)

start ruby tuple_server.rb startlocal && sleep 2
FOR /L %%i IN (1, 1, %TIMES%) DO sleep 1 && start ruby speak_server.rb startlocal
