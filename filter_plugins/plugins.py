# -*- Mode: Python -*-

import re
import json

from ansible import errors

def make_list(numof, start=0):
    """Make a list of increasing integers"""

# Ansible is ... strange:
#
#   - First exception is tossed when the task that includes the filter is
#     being executed, as you would expect
#   - Second exception however is tossed as soon as the playbook is started
#
# However, in all cases the argument is assigned the value from group_vars,
# and is not being overriden by cli arguments, i.e. -e "var=value"
#
#    raise errors.AnsibleFilterError("make_list was invoked: numof=%d, start=%d" % (numof, start))
#    raise errors.AnsibleFilterError("make_list was invoked!")

    return list(xrange(start, start+int(numof)))

def make_dict(data):
    """Make dictitonary from JSON document in string"""

#    raise errors.AnsibleFilterError("make_dict data: %s" % data)
#    raise errors.AnsibleFilterError("make_dict result: %s" % str(json.loads(data)))
#    raise errors.AnsibleFilterError("make_dict result type: %s" % type(json.loads(data)))
    return json.loads(data)

def are_vms_in_state(data):
    """Test if the results indicate all virtual machines are the desired state"""

    for result in data["results"]:
        if result["changed"] and result["stdout"] != 'yes':
            return(False)
    return(True)

def list_length(data):
    """Report the list length"""
    return len(data)

def filter_vm_by_name(data, name_pattern):
    """Filter out list of virtual machine names"""

    return [ vm_name for vm_name in data if re.search(name_pattern, vm_name) ]

def filter_vm_info_by_name(data, name_pattern):
    """Filter out list of virtual machine info structures"""

    return { k:v for k,v in data.items() if re.search(name_pattern, k) }

class FilterModule(object):
    ''' Ansible misc jinja2 filters '''

    def filters(self):
        return {
            'make_list':        make_list,
            'make_dict':        make_dict,
            'list_len':         list_length,
            'vms_in_state':     are_vms_in_state,
            'vm_by_name':       filter_vm_by_name,
            'vm_info_by_name':  filter_vm_info_by_name,
        }