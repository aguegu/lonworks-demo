//{{NodeBuilder Code Wizard Start <CodeWizard Timestamp>
// Run on Thu Aug 22 10:10:42 2013, version 4.01.07
//
//}}NodeBuilder Code Wizard End
//{{NodeBuilder Code Wizard Start <CodeWizard Template>
//// <Template Revision="3"/>
//}}NodeBuilder Code Wizard End
//////////////////////////////////////////////////////////////////////////////
// File: demo.nc
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
// Written By:
//
// Description:
//
// demo.nc is the device's main Neuron C source file, which
// automatically includes other application-specific Neuron C source or header
// files as necessary. The demo.nc file also contains the
// system tasks (when(reset), etc), network variables and the file directory.
//
//////////////////////////////////////////////////////////////////////////////

#ifndef _demo_NC_
#define _demo_NC_

#define _CODEWIZARD_VERSION_3_TEMPLATES_

/////////////////////////////////////////////////////////////////////////////
// Connect with the Code Wizard library.
//
// Version 3 of these templates, released with NodeBuilder 4, introduce
// versioning to the CodeWizard library by name. While version 1 didn't use
// any library, version 2 references CodeWizard.lib. This release of the
// templates, revision 3, references CodeWizard-3.lib, thus supporting
// co-existence of both template versions 2 and 3.
//
// The CodeWizard library supplies most of the utility functions defined in
// CodeWizard.h. Source code for this library is available in your
// NodeBuilder\Templates\CodeWizard\vX\LibSrc folder within your local
// LonWorks folder, where 'vX' is v2 or v3 (v4, etc, in future versions),
// subject to  the revision number of this application framework template.
// The revision number of this application framework template can be found
// at the top of this file.
//
// By default, CodeWizard-3.lib will be pre-installed into your LonWorks\images
// folder, and can be referenced with the pragma library "$IMG$\CodeWizard-3.lib"
// directive.
// User-defined versions of CodeWizard-3.lib should be located elsewhere. Define
// the USER_DEFINED_CODEWIZARD_LIB macro in this case, and reference your own
// version of CodeWizard-3.lib through the NodeBuilder project manager or the
// pragma library directive. See Readme.txt in the library source code folder
// for considerations and instructions regarding rebuilding of this library.
//
/////////////////////////////////////////////////////////////////////////////
#ifdef  _NEURONC
#   ifndef _MODEL_FILE
#       ifndef USER_DEFINED_CODEWIZARD_LIB
#           pragma library "$IMG$\CodeWizard-3.lib"
#       endif // USER_DEFINED_CODEWIZARD_LIB
#    endif // _MODEL_FILE
#endif  // _NEURONC

/////////////////////////////////////////////////////////////////////////////
// Header Files
//
#include "demo.h"
#include "common.h"

//
// The FileDirectory variable contains the file directory. Please see
// filexfer.h and filesys.h for more details about the implementation of the
// file system and the file transfer protocol.
// Note a file directory must be defined whenever at least one configuration
// property is defined in a configuration property value file, or at least one
// user-defined file exists. A file directory must be defined independent of
// the CP access mechanism (file transfer or direct access).
// Note that a different layout of file directory will be compiled for each of
// these access methods. The two access methods are mutually exclusive.
//
#ifndef _USE_NO_CPARAMS_ACCESS
    DIRECTORY_STORAGE TFileDirectory FileDirectory = {
        FILE_DIRECTORY_VERSION,   // major and minor version number (one byte)
        NUM_FILES, {
#ifdef _USE_DIRECT_CPARAMS_ACCESS
            { cp_template_file_len,         TEMPLATE_TYPE,  cp_template_file },
            { cp_modifiable_value_file_len, VALUE_TYPE,     cp_modifiable_value_file },
            { cp_readonly_value_file_len,   VALUE_TYPE,     cp_readonly_value_file   }
#else   // def. _USE_FTP_CPARAMS_ACCESS
            { NULL_INFO, { 0ul, cp_template_file_len         },    TEMPLATE_TYPE, cp_template_file },
            { NULL_INFO, { 0ul, cp_modifiable_value_file_len },    VALUE_TYPE,    cp_modifiable_value_file },
            { NULL_INFO, { 0ul, cp_readonly_value_file_len   },    VALUE_TYPE,    cp_readonly_value_file }
#endif  // def. _USE_DIRECT_CPARAMS_ACCESS
        }
    };
#endif // def. _USE_NO_CPARAMS_ACCESS

//{{NodeBuilder Code Wizard Start
// The NodeBuilder Code Wizard will add and remove code here.
// DO NOT EDIT the NodeBuilder Code Wizard generated code in these blocks
// between {{NodeBuilder Code Wizard Start and }}NodeBuilder Code Wizard End

//<Include Enum Type Headers>
//
//<Global CP Family Declarations>
//
//<Include Headers>
#include "NodeObject.h"
//
//<Device CP Family Declarations>
//
//<Device CP Declarations>
//
//<Device Input NV Declarations>
//
//<Device Output NV Declarations>
//
// <Include NC>
#include "NodeObject.nc"
//
//}}NodeBuilder Code Wizard End


/////////////////////////////////////////////////////////////////////////////
// Neuron C Files
//
#include "common.nc"

#ifdef _USE_FTP_CPARAMS_ACCESS
    #include "fileSys.nc"
    #include "fileXfer.nc"
#endif

//{{NodeBuilder Code Wizard Start
// The NodeBuilder Code Wizard will add and remove code here.
// DO NOT EDIT the NodeBuilder Code Wizard generated code in these blocks!

//<Input NV>
//
//}}NodeBuilder Code Wizard End

//{{NodeBuilder Code Wizard Start
// The NodeBuilder Code Wizard will add and remove code here.
// DO NOT EDIT the NodeBuilder Code Wizard generated code in these blocks!

//<Input NV Define>
//
// The following code will be ignored if this Neuron C file is used without
// an input NV implemented.  The Code Wizard automatically enables
// the _HAS_INP_DEV_NV macro if there is at least one input NV implemented.
//
#ifdef _HAS_INP_DEV_NV
//
//<Device NV When>
//
//}}NodeBuilder Code Wizard End
{
    // TODO: Add code to handle input network variable processing
}
#endif  //_HAS_INP_DEV_NV

#include "macros.h"
#include "usart.h"
#include "system.nc"
#include "iec103.h"

IO_2 output bit beeper;
stimer repeating tim;

far uint8_t cache_rx[256];

far Package package_rx;
far Package package_tx;

far DatumList datumlist;

uint8_t package_received;

//#ifdef TICK_INTERVAL
//#undef TICK_INTERVAL
//#define TICK_INTERVAL 2
//#endif

network input SNVT_count nviAddressRs485 = 1;
network output SNVT_switch nvoCoverStatus;
network output SNVT_time_stamp nvoLastTiming;

int8_t processRxPackage(void);

//
// when(reset) executes when the device is reset. Make sure to keep
// your when(reset) task short, as a pending state change can not be
// confirmed until this task is completed.
// The executeOnEachFblock() function, which is part of the CodeWizard
// application framework and can be found in the common.nc source file,
// automatically re-triggers the watchdog timer with every 16th fblock, but
// time-consuming director implementations may require additional caution
// in this regard.
//
when (reset) {
    uint8_t i, j, k;

    initAllFblockData(TOTAL_FBLOCK_COUNT);
    executeOnEachFblock(0, FBC_WHEN_RESET);

    nvoCoverStatus.state = FALSE;

    usart_init();
    package_received = 0;

    memset((char*)&datumlist, 0, sizeof(datumlist));

    datumlist.datums[0].capacity = RECORD_RANK_1_CAPACITY;
    datumlist.datums[1].capacity = RECORD_RANK_2_CAPACITY;
    datumlist.datums[2].capacity = RECORD_RANK_3_CAPACITY;

    for (i = 0, k = 0; i < 3 ; i++) {
        for (j = 0; j < datumlist.datums[i].capacity; j++)
            datumlist.datums[i].records[j] = &(datumlist.records[k++]);
    }
}

when (usart_available()) {
	uint8_t cs_calc, cs_recv, i, len, address_recv;
	len = 0;

	cache_rx[4] = (uint8_t)usart_read();
	if (cache_rx[0] == 0x10 && cache_rx[4] == 0x16) {
		cs_calc = cache_rx[1] + cache_rx[2];
		cs_recv = cache_rx[3];
		address_recv = cache_rx[2];
		len = 5;
	} else if (cache_rx[0] == 0x68 &&
				cache_rx[3] == cache_rx[0] &&
				cache_rx[1] == cache_rx[2] &&
				usart_readBytes(cache_rx + 5, cache_rx[1] + 1) == cache_rx[1] + 1 &&
				cache_rx[cache_rx[1] + 5] == 0x16) {

		for (cs_calc = 0, i = 0; i < cache_rx[1]; i++)
			cs_calc += *(cache_rx + 4 + i);
		cs_recv = cache_rx[cache_rx[1]+4];
		address_recv = cache_rx[5];
		len = cache_rx[1]+6;
	}

	if (cs_calc == cs_recv &&
			(address_recv == (uint8_t) nviAddressRs485 || address_recv == 0 || address_recv == 255)) {
		memcpy(package_rx.record.buff, cache_rx, len);
		package_rx.record.length = len;
		package_received = 1;
	}

	memcpy(cache_rx, cache_rx + 1, 4);
}

when (package_received) {
    uint8_t * p;
	package_received = 0;
    p = package_rx.record.buff;

    if (*package_rx.record.buff == 0x68) {

        package_rx.control = p + 4;
        package_rx.address = p + 5;

        package_rx.frame68.header68 = (Header68 *)p;
        package_rx.frame68.asdu_buff = p + 6;
        package_rx.frame68.asdu_length = package_rx.record.length - 8;
        package_rx.frame68.crc = p + package_rx.record.length - 2;
        package_rx.frame68.end = p + package_rx.record.length - 1;

        package_rx.address = package_rx.record.buff + 5;
    } else if (*package_rx.record.buff == 0x10) {
        package_rx.control = p + 1;
        package_rx.address = p + 2;
        package_rx.frame10 = (Frame10 *) package_rx.record.buff;
    } else
        return;

    processRxPackage();
}

int8_t replyFrame10(uint8_t control) {
    Frame10 * p10;

    p10 = (Frame10 *) package_tx.record.buff;
    *p10 = REP_NULL;

    p10->address = nviAddressRs485;
    p10->control = control;
    p10->crc = p10->control + p10->address;

    package_tx.record.length = 5;
    return 5;
}

int8_t onRequest6803() {
    int8_t result;
    AsduHead *ah;
    ah = (AsduHead *) package_rx.frame68.asdu_buff;

    switch (ah->typ) {
    case 0X07 :
    case 0X0A :
    case 0X15 :
    case 0x40 :
        result = replyFrame10(0x28);
        break;
    default:
        result = -1;
        break;
    }

    return result;
}

int8_t onRequest6804() {
    uint8_t * p;
    p = package_rx.frame68.asdu_buff + 6;
    nvoLastTiming.second = (p[0] + (p[1] << 8)) / 1000;
    nvoLastTiming.minute = p[2] & 0x3f;
    nvoLastTiming.hour = p[3] & 0x1f;
    nvoLastTiming.day = p[4] & 0x1f;
    nvoLastTiming.month = p[5] & 0x0f;
    nvoLastTiming.year = (p[6] & 0x7f) + 0x780;
    return 0;
}

uint8_t replyRankQuery(uint8_t rank) {
    Datum * current_datum;
    Record * current_record;
    current_datum = &datumlist.datums[rank % 3];
    current_record = current_datum->records[current_datum->start];
    current_datum->start = (current_datum->start + 1) % current_datum->capacity;

    if (current_datum->length)
        current_datum->length --;

    package_tx.record.length = current_record->length;
    memcpy(package_tx.record.buff, current_record->buff,  current_record->length);

    return current_record->length;
}

void refresh() {
    uint8_t func;
    AsduHead *ah;

    func = *package_rx.control & 0x0f;

    switch(func) {
        case 0x03:
            ah = (AsduHead *) package_rx.frame68.asdu_buff;
            switch (ah->typ) {
            case 0x40:
                switch (ah->inf) {
                case 0x70:  // open
                    nvoCoverStatus.state = 1;
                    break;
                case 0x71:  // close
                    nvoCoverStatus.state = 0;
                    break;
                }
                break;
            }
            break;
        case 0x0b:
            if (datumlist.datums[2].length == 0) {
                // prepareAlarm();
                // prepareRealData();
            }
            break;
    }
}

int8_t processRxPackage() {
    int8_t result;
    uint8_t func;

    func = *package_rx.control & 0x0f;

    switch (func) {
    case 0x03:
        result = onRequest6803();
        break;
    case 0x04:
        result = onRequest6804();
        break;
    case 0x0a:
        if (datumlist.datums[0].length)
            replyRankQuery(0x00);
        else if (datumlist.datums[1].length)
            replyRankQuery(0x01);
        else
            replyFrame10(0x09);
        break;
    case 0x0b:
        if (datumlist.datums[0].length)
            replyRankQuery(0x00);
        else if (datumlist.datums[2].length)
            replyRankQuery(0x02);
        else
            replyFrame10(0x09);
        break;
    default:
        result = -1;
        break;
    }

    // usart_write(*package_rx.control);
    // usart_write(*package_rx.address);
    usart_writeBytes(package_tx.record.buff, package_tx.record.length);
    usart_flush();

    refresh();

    return result;
}


//
// when(offline) executes as the device enters the offline state.
// Make sure to keep this task short, as the state change can
// not be confirmed until this task is completed.
//
when (offline)
{
    executeOnEachFblock(0, FBC_WHEN_OFFLINE);
}

//
// when(online) executes as the device enters the online state.
// Make sure to keep this task short, as the state change can
// not be confirmed until this task is completed.
//
when (online)
{
    executeOnEachFblock(0, FBC_WHEN_ONLINE);
}

//
// when(wink) executes as the device receives a wink command, and regardless
// of the device's current state. Add code here to implement your device's
// specific wink-behavior. Your code should trigger an appropriate action,
// such as the brief flashing of an LED or the sounding of a buzzer, allowing
// maintenance staff to identify the device in the field.
// Under no circumstances should wink cause an action that could engage users,
// machinery or maintenance staff.
// Remember the wink task also executes in the unconfigured state. Application
// timers and other features that require the configured state should not be
// used in the implementation of your when(wink) task.
//
when (wink)
{
    // TODO: Implement appropriate wink behavior here
}


#ifdef _HAS_CHANGEABLE_NV

//
// CodeWizard automatically defines the _HAS_CHANGEABLE_NV macro, if at least
// one network variable with changeable type is implemented. The conditionally
// compiled code here implements the system callback routine used to report
// the true and current length of a given network variable back to the system
// firmware.
// Code Wizard also enables the callback by inserting the
// system_image_extensions pragma, see demo.h.
// Note that callback support requires version 14 system firmware (or better).
//
unsigned get_nv_length_override(unsigned nvIndex)
{
    unsigned uResult;

    // Assume no override
    uResult = 0xFF;

    // TO DO: add code to return the current length of the network variable
    // with index "nvIndex."
    // Example code follows:
    //
    // switch (nvIndex) {
    //     case nviChangeableNv::global_index:
    //         if (nviChangeableNv::cpNvType.type_category != NVT_CAT_INITIAL
    //          && nviChangeableNv::cpNvType.type_category != NVT_CAT_NUL) {
    //             uResult = nviChangeableNv::cpNvType.type_length;
    //         }
    //         break;
    // } // switch

    return uResult;
}

#endif  // #ifdef _HAS_CHANGEABLE_NV
#endif // _demo_NC_
