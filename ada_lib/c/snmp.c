#include <assert.h>
#include <net-snmp/net-snmp-config.h>
#include <net-snmp/types.h>
#include <stdlib.h>

netsnmp_session* 
allocate_snmp (void) {
    return (netsnmp_session*) malloc (sizeof (netsnmp_session));
}

int
snmp_check_sizes (
    unsigned                netsnmp_vardata_type,
    unsigned                variable_list_type,
    unsigned                pdu_type)
{
    int                     result = 1;

    if (sizeof (netsnmp_pdu) != pdu_type) {
        fprintf (stderr, "pdu_type size wrong. c: %u ada: %u\n", 
            sizeof (netsnmp_pdu), pdu_type);
        result = 0;
    }

    if (sizeof (netsnmp_variable_list) != variable_list_type) {
        fprintf (stderr, "netsnmp_variable_list size wrong. c: %u ada: %u\n", 
            sizeof (netsnmp_variable_list), variable_list_type);
        result = 0;
    }

    if (sizeof (netsnmp_vardata) != netsnmp_vardata_type) {
        fprintf (stderr, "netsnmp_vardata size wrong. c: %u ada: %u\n", 
            sizeof (netsnmp_vardata), netsnmp_vardata_type);
        result = 0;
    }

//printf("pdu_type size. c: %u ada: %u\n", sizeof (netsnmp_pdu), pdu_type);
//printf("netsnmp_variable_list size. c: %u ada: %u\n", sizeof (netsnmp_variable_list), variable_list_type);
//printf("netsnmp_vardata size. c: %u ada: %u\n", sizeof (netsnmp_vardata), netsnmp_vardata_type);
    return result;
}

void
free_snmp (
    netsnmp_session*        session) {

    assert (session != NULL);
    free (session);
}

//void
//set_options (
//    netsnmp_session*        session,
//    int                     version,
//    int                     timeout,
//    int                     retries) {
//
//    session->version = version;
//
//    if (timeout > 0) {
//        session->timeout = timeout;
//    }
//
//    if (retries > 0) {
//        session->retries = retries;
//    }
//}
