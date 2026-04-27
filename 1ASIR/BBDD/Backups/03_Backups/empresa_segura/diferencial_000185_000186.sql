# The proper term is pseudo_replica_mode, but we use this compatibility alias
# to make the statement usable on server versions 8.0.24 and older.
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=1*/;
/*!50003 SET @OLD_COMPLETION_TYPE=@@COMPLETION_TYPE,COMPLETION_TYPE=0*/;
DELIMITER /*!*/;
# at 4
#260421  8:34:20 server id 1  end_log_pos 126 CRC32 0x6a0cf987 	Start: binlog v 4, server v 8.0.43-0ubuntu0.22.04.1 created 260421  8:34:20 at startup
ROLLBACK/*!*/;
BINLOG '
bBrnaQ8BAAAAegAAAH4AAAAAAAQAOC4wLjQzLTB1YnVudHUwLjIyLjA0LjEAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAABsGudpEwANAAgAAAAABAAEAAAAYgAEGggAAAAICAgCAAAACgoKKioAEjQA
CigAAYf5DGo=
'/*!*/;
# at 126
#260421  8:34:20 server id 1  end_log_pos 157 CRC32 0xa15369c1 	Previous-GTIDs
# [empty]
# at 157
#260421 10:51:55 server id 1  end_log_pos 201 CRC32 0xa82f3f44 	Rotate to binlog.000186  pos: 4
SET @@SESSION.GTID_NEXT= 'AUTOMATIC' /* added by mysqlbinlog */ /*!*/;
DELIMITER ;
# End of log file
/*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=0*/;
# The proper term is pseudo_replica_mode, but we use this compatibility alias
# to make the statement usable on server versions 8.0.24 and older.
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=1*/;
/*!50003 SET @OLD_COMPLETION_TYPE=@@COMPLETION_TYPE,COMPLETION_TYPE=0*/;
DELIMITER /*!*/;
# at 4
#260421 10:51:55 server id 1  end_log_pos 126 CRC32 0xd8f796f0 	Start: binlog v 4, server v 8.0.43-0ubuntu0.22.04.1 created 260421 10:51:55
BINLOG '
qzrnaQ8BAAAAegAAAH4AAAAAAAQAOC4wLjQzLTB1YnVudHUwLjIyLjA0LjEAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAEwANAAgAAAAABAAEAAAAYgAEGggAAAAICAgCAAAACgoKKioAEjQA
CigAAfCW99g=
'/*!*/;
# at 126
#260421 10:51:55 server id 1  end_log_pos 157 CRC32 0xc0c66488 	Previous-GTIDs
# [empty]
# at 157
#260421 10:58:21 server id 1  end_log_pos 201 CRC32 0x3cea5781 	Rotate to binlog.000187  pos: 4
SET @@SESSION.GTID_NEXT= 'AUTOMATIC' /* added by mysqlbinlog */ /*!*/;
DELIMITER ;
# End of log file
/*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=0*/;
