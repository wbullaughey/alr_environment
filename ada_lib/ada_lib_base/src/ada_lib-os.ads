with Ada.Exceptions;
with GNAT.OS_Lib;
with GNAT.Source_Info;

package Ada_Lib.OS is

   Failed                        : exception;

   type Priority_Type            is range -20 .. 19;

   Default_Priority              : constant Priority_Type := 0;
   PRIO_PROCESS                  : constant := 0;
   Temp_File_Length              : constant Integer := 12;


-- subtype OS_Exit_Code_Type        is Integer range -128 .. 127;

   type OS_Exit_Code_Type           is (  -- macos errors
      No_Error,
      Operation_not_permitted,                            -- EPERM
      No_such_file_or_directory,                          -- ENOENT
      No_such_process,                                    -- ESRCH
      Interrupted_system_call,                            -- EINTR
      Input_Output_error,                                 -- EIO
      No_such_device_or_address,                          -- ENXIO
      Argument_list_too_long,                             -- E2BIG
      Exec_format_error,                                  -- ENOEXEC
      Bad_file_descriptor,                                -- EBADF
      No_child_processes,                                -- ECHILD
      Resource_temporarily_unavailable,                  -- EAGAIN EWOULDBLOCK
      Cannot_allocate_memory,                            -- ENOMEM
      Permission_denied,                                 -- EACCES
      Bad_address,                                       -- EFAULT
      Block_device_required,                             -- ENOTBLK
      Device_or_resource_busy,                           -- EBUSY
      File_exists,                                       -- EEXIST
      Invalid_cross_device_link,                         -- EXDEV
      No_such_device,                                    -- ENODEV
      Not_a_directory,                                   -- ENOTDIR
      Is_a_directory,                                    -- EISDIR
      Invalid_argument,                                  -- EINVAL
      Too_many_open_files_in_system,                     -- ENFILE
      Too_many_open_files,                               -- EMFILE
      Inappropriate_ioctl_for_device,                    -- ENOTTY
      Text_file_busy,                                    -- ETXTBSY
      File_too_large,                                    -- EFBIG
      No_space_left_on_device,                           -- ENOSPC
      Illegal_seek,                                      -- ESPIPE
      Read_only_file_system,                             -- EROFS
      Too_many_links,                                    -- EMLINK
      Broken_pipe,                                       -- EPIPE
      Numerical_argument_out_of_domain,                  -- EDOM
      Numerical_result_out_of_range,                     -- ERANGE
      Resource_deadlock_avoided,                         -- EDEADLK EDEADLOCK
      File_name_too_long,                                -- ENAMETOOLONG
      No_locks_available,                                -- ENOLCK
      Function_not_implemented,                          -- ENOSYS
      Directory_not_empty,                               -- ENOTEMPTY
      Too_many_levels_of_symbolic_links,                 -- ELOOP
      implemented,                                       -- not
      No_message_of_desired_type,                        -- ENOMSG
      Identifier_removed,                                -- EIDRM
      Channel_number_out_of_range,                       -- ECHRNG
      Level_2_not_synchronized,                          -- EL2NSYNC
      Level_3_halted,                                    -- EL3HLT
      Level_3_reset,                                     -- EL3RST
      Link_number_out_of_range,                          -- ELNRNG
      Protocol_driver_not_attached,                      -- EUNATCH
      No_CSI_structure_available,                        -- ENOCSI
      Level_2_halted,                                    -- EL2HLT
      Invalid_exchange,                                  -- EBADE
      Invalid_request_descriptor,                        -- EBADR
      Exchange_full,                                     -- EXFULL
      No_anode,                                          -- ENOANO
      Invalid_request_code,                              -- EBADRQC
      Invalid_slot,                                      -- EBADSLT
      Bad_font_file_format,                              -- EBFONT
      Device_not_a_stream,                               -- ENOSTR
      No_data_available,                                 -- ENODATA
      Timer_expired,                                     -- ETIME
      Out_of_streams_resources,                          -- ENOSR
      Machine_is_not_on_the_network,                     -- ENONET
      Package_not_installed,                             -- ENOPKG
      Object_is_remote,                                  -- EREMOTE
      Link_has_been_severed,                             -- ENOLINK
      Advertise_error,                                   -- EADV
      Srmount_error,                                     -- ESRMNT
      Communication_error_on_send,                       -- ECOMM
      Protocol_error,                                    -- EPROTO
      Multihop_attempted,                                -- EMULTIHOP
      RFS_specific_error,                                -- EDOTDOT
      Bad_message,                                       -- EBADMSG
      Value_too_large_for_defined_data_type,             -- EOVERFLOW
      Name_not_unique_on_network,                        -- ENOTUNIQ
      File_descriptor_in_bad_state,                      -- EBADFD
      Remote_address_changed,                            -- EREMCHG
      Can_not_access_a_needed_shared_library,            -- ELIBACC
      Accessing_a_corrupted_shared_library,              -- ELIBBAD
      Lib_section_in_a_out_corrupted,                   -- ELIBSCN
      Attempting_to_link_in_too_many_shared_libraries,   -- ELIBMAX
      Cannot_exec_a_shared_library_directly,             -- ELIBEXEC
      Invalid_or_incomplete_multibyte_or_wide_character, -- EILSEQ
      Interrupted_system_call_should_be_restarted,       -- ERESTART
      Streams_pipe_error,                                -- ESTRPIPE
      Too_many_users,                                    -- EUSERS
      Socket_operation_on_non_socket,                    -- ENOTSOCK
      Destination_address_required,                      -- EDESTADDRREQ
      Message_too_long,                                  -- EMSGSIZE
      Protocol_wrong_type_for_socket,                    -- EPROTOTYPE
      Protocol_not_available,                            -- ENOPROTOOPT
      Protocol_not_supported,                            -- EPROTONOSUPPORT
      Socket_type_not_supported,                         -- ESOCKTNOSUPPORT
      Operation_not_supported,                           -- EOPNOTSUPP ENOTSUP
      Protocol_family_not_supported,                     -- EPFNOSUPPORT
      Address_family_not_supported_by_protocol,          -- EAFNOSUPPORT
      Address_already_in_use,                            -- EADDRINUSE
      Cannot_assign_requested_address,                   -- EADDRNOTAVAIL
      Network_is_down,                                   -- ENETDOWN
      Network_is_unreachable,                            -- ENETUNREACH
      Network_dropped_connection_on_reset,               -- ENETRESET
      Software_caused_connection_abort,                  -- ECONNABORTED
      Connection_reset_by_peer,                          -- ECONNRESET
      No_buffer_space_available,                         -- ENOBUFS
      Transport_endpoint_is_already_connected,           -- EISCONN
      Transport_endpoint_is_not_connected,               -- ENOTCONN
      Cannot_send_after_transport_endpoint_shutdown,     -- ESHUTDOWN
      Too_many_references_cannot_splice,                 -- ETOOMANYREFS
      Connection_timed_out,                              -- ETIMEDOUT
      Connection_refused,                                -- ECONNREFUSED
      Host_is_down,                                      -- EHOSTDOWN
      No_route_to_host,                                  -- EHOSTUNREACH
      Operation_already_in_progress,                     -- EALREADY
      Operation_now_in_progress,                         -- EINPROGRESS
      Stale_file_handle,                                 -- ESTALE
      Structure_needs_cleaning,                          -- EUCLEAN
      Not_a_XENIX_named_type_file,                       -- ENOTNAM
      No_XENIX_semaphores_available,                     -- ENAVAIL
      Is_a_named_type_file,                              -- EISNAM
      Remote_I_O_error,                                  -- EREMOTEIO
      Disk_quota_exceeded,                               -- EDQUOT
      No_medium_found,                                   -- ENOMEDIUM
      Wrong_medium_type,                                 -- EMEDIUMTYPE
      Operation_canceled,                                -- ECANCELED
      Required_key_not_available,                        -- ENOKEY
      Key_has_expired,                                   -- EKEYEXPIRED
      Key_has_been_revoked,                              -- EKEYREVOKED
      Key_was_rejected_by_service,                       -- EKEYREJECTED
      Owner_died,                                        -- EOWNERDEAD
      State_not_recoverable,                             -- ENOTRECOVERABLE
      Operation_not_possible_due_to_RF_kill,             -- ERFKILL
      Memory_page_has_hardware_error,                    -- EHWPOISON
      Application_Error,
      Assertion_Exit,
      Exception_Exit,
      Not_Implemented_Exit,
      Recursion_Exit,
      Unit_Test_Set_Up_Exception,
      Unit_Test_Tear_Down_Exception,
      Unassigned);                                       -- no equivalent Linux code,

   for OS_Exit_Code_Type'size use 8;
   for OS_Exit_Code_Type use (
      No_Error => 0,
      Operation_not_permitted => 1,                            -- EPERM
      No_such_file_or_directory => 2,                          -- ENOENT
      No_such_process => 3,                                    -- ESRCH
      Interrupted_system_call => 4,                            -- EINTR
      Input_Output_error => 5,                                 -- EIO
      No_such_device_or_address => 6,                          -- ENXIO
      Argument_list_too_long => 7,                             -- E2BIG
      Exec_format_error => 8,                                  -- ENOEXEC
      Bad_file_descriptor => 9,                                -- EBADF
      No_child_processes => 10,                                -- ECHILD
      Resource_temporarily_unavailable => 11,                  -- EAGAIN
      Cannot_allocate_memory => 12,                            -- ENOMEM
      Permission_denied => 13,                                 -- EACCES
      Bad_address => 14,                                       -- EFAULT
      Block_device_required => 15,                             -- ENOTBLK
      Device_or_resource_busy => 16,                           -- EBUSY
      File_exists => 17,                                       -- EEXIST
      Invalid_cross_device_link => 18,                         -- EXDEV
      No_such_device => 19,                                    -- ENODEV
      Not_a_directory => 20,                                   -- ENOTDIR
      Is_a_directory => 21,                                    -- EISDIR
      Invalid_argument => 22,                                  -- EINVAL
      Too_many_open_files_in_system => 23,                     -- ENFILE
      Too_many_open_files => 24,                               -- EMFILE
      Inappropriate_ioctl_for_device => 25,                    -- ENOTTY
      Text_file_busy => 26,                                    -- ETXTBSY
      File_too_large => 27,                                    -- EFBIG
      No_space_left_on_device => 28,                           -- ENOSPC
      Illegal_seek => 29,                                      -- ESPIPE
      Read_only_file_system => 30,                             -- EROFS
      Too_many_links => 31,                                    -- EMLINK
      Broken_pipe => 32,                                       -- EPIPE
      Numerical_argument_out_of_domain => 33,                  -- EDOM
      Numerical_result_out_of_range => 34,                     -- ERANGE
      Resource_deadlock_avoided => 35,                         -- EDEADLK EDEADLOCK
      File_name_too_long => 36,                                -- ENAMETOOLONG
      No_locks_available => 37,                                -- ENOLCK
      Function_not_implemented => 38,                          -- ENOSYS
      Directory_not_empty => 39,                               -- ENOTEMPTY
      Too_many_levels_of_symbolic_links => 40,                 -- ELOOP
      implemented => 41,                                       -- not
      No_message_of_desired_type => 42,                        -- ENOMSG
      Identifier_removed => 43,                                -- EIDRM
      Channel_number_out_of_range => 44,                       -- ECHRNG
      Level_2_not_synchronized => 45,                          -- EL2NSYNC
      Level_3_halted => 46,                                    -- EL3HLT
      Level_3_reset => 47,                                     -- EL3RST
      Link_number_out_of_range => 48,                          -- ELNRNG
      Protocol_driver_not_attached => 49,                      -- EUNATCH
      No_CSI_structure_available => 50,                        -- ENOCSI
      Level_2_halted => 51,                                    -- EL2HLT
      Invalid_exchange => 52,                                  -- EBADE
      Invalid_request_descriptor => 53,                        -- EBADR
      Exchange_full => 54,                                     -- EXFULL
      No_anode => 55,                                          -- ENOANO
      Invalid_request_code => 56,                              -- EBADRQC
      Invalid_slot => 57,                                      -- EBADSLT
      Bad_font_file_format => 59,                              -- EBFONT
      Device_not_a_stream => 60,                               -- ENOSTR
      No_data_available => 61,                                 -- ENODATA
      Timer_expired => 62,                                     -- ETIME
      Out_of_streams_resources => 63,                          -- ENOSR
      Machine_is_not_on_the_network => 64,                     -- ENONET
      Package_not_installed => 65,                             -- ENOPKG
      Object_is_remote => 66,                                  -- EREMOTE
      Link_has_been_severed => 67,                             -- ENOLINK
      Advertise_error => 68,                                   -- EADV
      Srmount_error => 69,                                     -- ESRMNT
      Communication_error_on_send => 70,                       -- ECOMM
      Protocol_error => 71,                                    -- EPROTO
      Multihop_attempted => 72,                                -- EMULTIHOP
      RFS_specific_error => 73,                                -- EDOTDOT
      Bad_message => 74,                                       -- EBADMSG
      Value_too_large_for_defined_data_type => 75,             -- EOVERFLOW
      Name_not_unique_on_network => 76,                        -- ENOTUNIQ
      File_descriptor_in_bad_state => 77,                      -- EBADFD
      Remote_address_changed => 78,                            -- EREMCHG
      Can_not_access_a_needed_shared_library => 79,            -- ELIBACC
      Accessing_a_corrupted_shared_library => 80,              -- ELIBBAD
      Lib_section_in_a_out_corrupted => 81,                    -- ELIBSCN
      Attempting_to_link_in_too_many_shared_libraries => 82,   -- ELIBMAX
      Cannot_exec_a_shared_library_directly => 83,             -- ELIBEXEC
      Invalid_or_incomplete_multibyte_or_wide_character => 84, -- EILSEQ
      Interrupted_system_call_should_be_restarted => 85,       -- ERESTART
      Streams_pipe_error => 86,                                -- ESTRPIPE
      Too_many_users => 87,                                    -- EUSERS
      Socket_operation_on_non_socket => 88,                    -- ENOTSOCK
      Destination_address_required => 89,                      -- EDESTADDRREQ
      Message_too_long => 90,                                  -- EMSGSIZE
      Protocol_wrong_type_for_socket => 91,                    -- EPROTOTYPE
      Protocol_not_available => 92,                            -- ENOPROTOOPT
      Protocol_not_supported => 93,                            -- EPROTONOSUPPORT
      Socket_type_not_supported => 94,                         -- ESOCKTNOSUPPORT
      Operation_not_supported => 95,                           -- EOPNOTSUPP ENOTSUP
      Protocol_family_not_supported => 96,                     -- EPFNOSUPPORT
      Address_family_not_supported_by_protocol => 97,          -- EAFNOSUPPORT
      Address_already_in_use => 98,                            -- EADDRINUSE
      Cannot_assign_requested_address => 99,                   -- EADDRNOTAVAIL
      Network_is_down => 100,                                  -- ENETDOWN
      Network_is_unreachable => 101,                           -- ENETUNREACH
      Network_dropped_connection_on_reset => 102,              -- ENETRESET
      Software_caused_connection_abort => 103,                 -- ECONNABORTED
      Connection_reset_by_peer => 104,                         -- ECONNRESET
      No_buffer_space_available => 105,                        -- ENOBUFS
      Transport_endpoint_is_already_connected => 106,          -- EISCONN
      Transport_endpoint_is_not_connected => 107,              -- ENOTCONN
      Cannot_send_after_transport_endpoint_shutdown => 108,    -- ESHUTDOWN
      Too_many_references_cannot_splice => 109,                -- ETOOMANYREFS
      Connection_timed_out => 110,                             -- ETIMEDOUT
      Connection_refused => 111,                               -- ECONNREFUSED
      Host_is_down => 112,                                     -- EHOSTDOWN
      No_route_to_host => 113,                                 -- EHOSTUNREACH
      Operation_already_in_progress => 114,                    -- EALREADY
      Operation_now_in_progress => 115,                        -- EINPROGRESS
      Stale_file_handle => 116,                                -- ESTALE
      Structure_needs_cleaning => 117,                         -- EUCLEAN
      Not_a_XENIX_named_type_file => 118,                      -- ENOTNAM
      No_XENIX_semaphores_available => 119,                    -- ENAVAIL
      Is_a_named_type_file => 120,                             -- EISNAM
      Remote_I_O_error => 121,                                 -- EREMOTEIO
      Disk_quota_exceeded => 122,                              -- EDQUOT
      No_medium_found => 123,                                  -- ENOMEDIUM
      Wrong_medium_type => 124,                                -- EMEDIUMTYPE
      Operation_canceled => 125,                               -- ECANCELED
      Required_key_not_available => 126,                       -- ENOKEY
      Key_has_expired => 127,                                  -- EKEYEXPIRED
      Key_has_been_revoked => 128,                             -- EKEYREVOKED
      Key_was_rejected_by_service => 129,                      -- EKEYREJECTED
      Owner_died => 130,                                       -- EOWNERDEAD
      State_not_recoverable => 131,                            -- ENOTRECOVERABLE
      Operation_not_possible_due_to_RF_kill => 132,            -- ERFKILL
      Memory_page_has_hardware_error => 133,                   -- EHWPOISON
      Application_Error =>200,
      Assertion_Exit => 201,
      Exception_Exit => 202,
      Not_Implemented_Exit => 203,
      Recursion_Exit => 204,
      Unit_Test_Set_Up_Exception => 205,
      Unit_Test_Tear_Down_Exception => 206,
      Unassigned => 255);

   subtype File_Descriptor       is GNAT.OS_Lib.File_Descriptor;
   type Process_Id_Type          is new Integer;
   subtype Temporary_File_Name   is String (1 .. Temp_File_Length);

   procedure Exception_Halt (
      Fault                      : in     Ada.Exceptions.Exception_Occurrence;
      Message                    : in     String := "";
      From                       : in     String := GNAT.Source_Info.Source_Location);

   function Get_Environment (
      Name                       : in     String
   ) return String;

   function Get_Host_Name
   return String;

   function Get_User
   return String;

   procedure Immediate_Halt (
      Exit_Code                  : in     OS_Exit_Code_Type;
      Message                    : in     String := "";
      From                       : in     String := GNAT.Source_Info.Source_Location);

   procedure Close_File (
      File                       : in     File_Descriptor) renames
                                             GNAT.OS_Lib.Close;

   procedure Create_Scratch_File (
      File                       :    out File_Descriptor;
      Name                       :    out Temporary_File_Name) renames
                                       GNAT.OS_Lib.Create_Temp_File;

   -- creates scrtach file and returns its name
   function Create_Scratch_File
   return String;

   procedure Set_Priority (
      Priority                   : in     Priority_Type);

   function Self
   return Process_Id_Type;

   function Self
   return String;

   subtype Argument_Array     is GNAT.OS_Lib.String_List;

   Trace        : aliased Boolean := False;
end Ada_Lib.OS;
