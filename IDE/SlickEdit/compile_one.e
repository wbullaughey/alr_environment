#include "slick.sh"

_command void compile_current_file() name_info(','VSARG2_MACRO)
{
   save_all();

   _str compile_script = "/Users/wayne/Project/git/alr/alr_environment/IDE/SlickEdit/compile_current_file.sh";
   _str filename = p_buf_name;

   _str cmd = '"' :+ compile_script :+ '" "' :+ filename :+ '"';
   restart_process();
   concur_command(cmd);
}
