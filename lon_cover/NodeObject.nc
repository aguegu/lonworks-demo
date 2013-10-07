//{{NodeBuilder Code Wizard Start <CodeWizard Timestamp>
// Run on Mon Oct 07 10:18:26 2013, version 4.01.07
//
//}}NodeBuilder Code Wizard End
//{{NodeBuilder Code Wizard Start <CodeWizard Template>
//// <Template Revision="3"/>
//}}NodeBuilder Code Wizard End

//////////////////////////////////////////////////////////////////
// File: NodeObject.nc
//
//
// Generated by NodeBuilder Code Wizard Version 4.01.07
// Copyright (c) 2001-2009 Echelon Corporation.  All rights reserved.
//                                                                                  
// ECHELON MAKES NO REPRESENTATION, WARRANTY, OR CONDITION OF
// ANY KIND, EXPRESS, IMPLIED, STATUTORY, OR OTHERWISE OR IN
// ANY COMMUNICATION WITH YOU, INCLUDING, BUT NOT LIMITED TO,
// ANY IMPLIED WARRANTIES OF MERCHANTABILITY, SATISFACTORY
// QUALITY, FITNESS FOR ANY PARTICULAR PURPOSE, 
// NONINFRINGEMENT, AND THEIR EQUIVALENTS.
//
//
// Written By: NodeBuilder Code Wizard
//
// Description: Node Object functions
// This file contains functions that handle the node object. Requests relating
// to other objects are automatically routed to the relevant director function.
//
// The referenced SFPTnodeObject functional profile specification is available
// online at http://www.lonmark.org/profiles/0000_20.pdf
// The latest versions of the profile specifications can be obtained from
// http://www.lonmark.org/profiles/
//
//////////////////////////////////////////////////////////////////////////////

#include "NodeObject.h"

//
// Task to handle device and object related requests.
//
// The SNVT_request input network variable receives commands (requests) for
// an individual object (object_id > 0), or for the entire device
// (object_id == 0). This network variable update handler routes the command
// to the appropriate director function(s) when appropriate, or handles the
// request locally where possible.
// Make sure to review the default handling of commands in the director
// implementations provided within each functional block code module.
//
when (nv_update_occurs(NBCW_NODE_REQUEST))
{
    unsigned uFbIndex;
    object_request_t objectRequest;
    TFblockData *pStatus;
    TStatusUnion oStatus;

    uFbIndex = (unsigned)NBCW_NODE_REQUEST.object_id;
    pStatus = getObjStatus(uFbIndex);   // point to current status
    objectRequest = NBCW_NODE_REQUEST.object_request;  // get request code

    pStatus->invalid_id = FALSE;        // default

    if (uFbIndex >= (unsigned)TOTAL_FBLOCK_COUNT)  {
        pStatus->invalid_id = TRUE;  // no such object
    } else if (objectRequest == RQ_REPORT_MASK) {
        if (uFbIndex) {
            // The fblock code must copy its report mask to NBCW_NODE_STATUS
            fblock_director(uFbIndex, FBC_REPORT_MASK);
        } else {
            NBCW_NODE_STATUS = NodeObjectReportMask;
        }
        NBCW_NODE_STATUS.object_id = NBCW_NODE_REQUEST.object_id;
        return;  // bail out here
    } else if (objectRequest >= RQ_NORMAL) {
        pStatus->invalid_request = FALSE;    // default

        if (uFbIndex) {
            fblock_director(uFbIndex, objectRequest);
        } else {
            if (objectRequest == RQ_UPDATE_STATUS) {
                updateNode_Status(NODEOBJ_INDEX, TOTAL_FBLOCK_COUNT);
            } else if (objectRequest == RQ_CLEAR_STATUS) {
                executeOnEachFblock(1+NODEOBJ_INDEX, RQ_CLEAR_STATUS);
                updateNode_Status(NODEOBJ_INDEX, TOTAL_FBLOCK_COUNT);
            } else if (objectRequest == RQ_SELF_TEST) {
                //
                // TODO:
                // To support a device-wide self-test routine, which might be
                // different than the sum of all self-test routines that apply
                // to individual fblocks, replace the following line with code
                // that executes such a device-wide self-test:
                //

                pStatus->invalid_request = TRUE;

            } else if ((objectRequest == RQ_UPDATE_ALARM)
                    || (objectRequest == RQ_CLEAR_ALARM)) {
                //
                // TODO: to support device-level alarms, as described in the
                // SFPTnodeObject functional profile, replace the following
                // line with code that handles update_alarm and clear_alarm
                // requests for device-level alarms:
                //

                pStatus->invalid_request = TRUE;

            } else {
                executeOnEachFblock(1+NODEOBJ_INDEX, objectRequest);
                updateNode_Status(NODEOBJ_INDEX, TOTAL_FBLOCK_COUNT);
            }
        }
    } else {
        pStatus->invalid_request = TRUE;
    }

    oStatus.fbStatus.fbData = *pStatus;
    oStatus.fbStatus.objectId = uFbIndex;
    NBCW_NODE_STATUS = oStatus.objStatus;
}

void NodeObjectDirector(unsigned uFblockIndex, int nCommand) {
    // The node object director function is not used by the standard framework.
    // You may add code here to control the node object itself.
#pragma ignore_notused uFblockIndex
#pragma ignore_notused nCommand
}

//
// The Node Object's report mask indicates features supported by the object
// with object_id 0 (the node object). The SFPTnodeObject functional profile
// specifies how the node object should handle these requests.
//
const SNVT_obj_status NodeObjectReportMask = {
    0,              // object_id

    0,              // invalid_id
    0,              // invalid_request
    1,              // disabled
    0,              // out_of_limits
    0,              // open_circuit
    0,              // out_of_service
    0,              // mechanical_fault
    0,              // feedback_failure

    0,              // over_range
    0,              // under_range
    0,              // electrical_fault
    0,              // unable_to_measure
    0,              // comm_failure
    0,              // fail_self_test
    0,              // self_test_in_progress
    0,              // locked_out

    0,              // manual_control
    0,              // in_alarm
    1,              // in_override
    1,              // report_mask
    0,              // programming_mode
    0,              // programming_failed
    0,              // alarm_notify_disabled
    0               // reset_complete
};












