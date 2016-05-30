MODULE_NAME='featureInputDetection_DVX' (DEV panels[], INTEGER signalInputs[][])
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/30/2016  AT: 14:01:48        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)
#INCLUDE 'SNAPI'
#INCLUDE 'CHAPI'

#INCLUDE 'amx_panel_control_v2'
#INCLUDE 'amx_string_control'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

INTEGER tlRunFirst = 1
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

STRUCT __SIGNAL_STATUS
{
	INTEGER btnNumber
	INTEGER inputNumber
	INTEGER validSignal
}
(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG ltimesRunFirst[] = {5000}

DEV dvDVX[] = {5002: 1:0, 5002: 2:0, 5002: 3:0, 5002: 4:0, 5002: 5:0,
							 5002: 6:0, 5002: 7:0, 5002: 8:0, 5002: 9:0, 5002:10:0}

__SIGNAL_STATUS signalStatus[100]
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

TIMELINE_CREATE(tlRunFirst,ltimesRunFirst,LENGTH_ARRAY(ltimesRunFirst),TIMELINE_ABSOLUTE,TIMELINE_ONCE)
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

TIMELINE_EVENT[tlRunFirst]
{
	STACK_VAR INTEGER idx

	FOR(idx=1;idx<=100;idx++)
	{
		signalStatus[idx].btnNumber = signalInputs[1][idx]
		signalStatus[idx].inputNumber = signalInputs[2][idx]
	}

	FOR(idx=1;idx<=LENGTH_ARRAY(dvDVX);idx++)
	{
		tpButtonHide(panels,signalStatus[idx].btnNumber)
		SEND_COMMAND dvDVX[idx],'?VIDIN_STATUS'
	}
}

DATA_EVENT[panels]
{
	ONLINE:
	{
		STACK_VAR INTEGER	idx

		FOR(idx=1;idx<=LENGTH_ARRAY(dvDVX);idx++)
		{
			IF(signalStatus[idx].validSignal==true)
				tpButtonShow(panels,signalStatus[idx].btnNumber)
			ELSE
				tpButtonHide(panels,signalStatus[idx].btnNumber)
		}
	}
}

DATA_EVENT[dvDVX]
{
	COMMAND:
	{
		STACK_VAR INTEGER idx

		IF(FIND_STRING(DATA.TEXT,'VIDIN_STATUS-',1))
		{
			REMOVE_STRING(DATA.TEXT,'VIDIN_STATUS-',1)

			//check if signal is defined
			FOR(idx=1;idx<=100;idx++)
			{
				IF(signalStatus[idx].inputNumber==DATA.DEVICE.PORT)
				{
					SELECT
					{
						ACTIVE(DATA.TEXT=='VALID SIGNAL'):
						{
							signalStatus[idx].validSignal = true
							tpButtonShow(panels,signalStatus[idx].btnNumber)
						}
						ACTIVE(1):
						{
							signalStatus[idx].validSignal = false
							tpButtonHide(panels,signalStatus[idx].btnNumber)
						}
					}
					BREAK
				}
			}
		}
	}
}
(*****************************************************************)
(*                       END OF PROGRAM                          *)
(*                                                               *)
(*         !!!  DO NOT PUT ANY CODE BELOW THIS COMMENT  !!!      *)
(*                                                               *)
(*****************************************************************)
