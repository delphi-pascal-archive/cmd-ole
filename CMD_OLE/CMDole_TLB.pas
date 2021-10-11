unit CMDole_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 01.11.2007 21:08:49 from Type Library described below.

// ************************************************************************  //
// LIBID: {2D7C0BE7-282C-4C4E-B71A-144B2064C972}
// LCID: 0
// Helpfile: 
// HelpString: CMDole Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\system32\stdole2.tlb)
// ************************************************************************ //

{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//

const
  // TypeLibrary Major and minor versions
  CMDoleMajorVersion = 1;
  CMDoleMinorVersion = 0;

  LIBID_CMDole: TGUID = '{2D7C0BE7-282C-4C4E-B71A-144B2064C972}';

  IID_Iserver: TGUID = '{829E8E82-EC11-45E3-970B-C364928F2449}';
  CLASS_server: TGUID = '{4F14750A-513E-493C-A19B-06EEDA875D07}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  Iserver = interface;
  IserverDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  server = Iserver;

// *********************************************************************//
// Interface: Iserver
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {829E8E82-EC11-45E3-970B-C364928F2449}
// *********************************************************************//
  Iserver = interface(IDispatch)
    ['{829E8E82-EC11-45E3-970B-C364928F2449}']
    procedure CmdOut(const Param1: WideString); safecall;
    function Get_CmdStatus: WideString; safecall;
    procedure CmdSet(const Param1: WideString); safecall;
    function Get_TextIn: WideString; safecall;
    function Get_LineNbIn: Integer; safecall;
    function Get_LineIn(Param1: Integer): WideString; safecall;
    procedure FilterSet(const Param1: WideString); safecall;
    procedure FilterFor(Param1: Integer; const Param2: WideString; const Param3: WideString); safecall;
    procedure WaitFor(Param1: Integer; const Param2: WideString; const Param3: WideString); safecall;
    procedure WaitReset; safecall;
    function Get_WaitStatus: Integer; safecall;
    procedure InitReset; safecall;
    function Get_Path: WideString; safecall;
    procedure Show(Param1: Integer); safecall;
    procedure UserOut(const Param1: WideString; const Param2: WideString); safecall;
    procedure PasswOut(const Param1: WideString; const Param2: WideString); safecall;
    property CmdStatus: WideString read Get_CmdStatus;
    property TextIn: WideString read Get_TextIn;
    property LineNbIn: Integer read Get_LineNbIn;
    property LineIn[Param1: Integer]: WideString read Get_LineIn;
    property WaitStatus: Integer read Get_WaitStatus;
    property Path: WideString read Get_Path;
  end;

// *********************************************************************//
// DispIntf:  IserverDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {829E8E82-EC11-45E3-970B-C364928F2449}
// *********************************************************************//
  IserverDisp = dispinterface
    ['{829E8E82-EC11-45E3-970B-C364928F2449}']
    procedure CmdOut(const Param1: WideString); dispid 201;
    property CmdStatus: WideString readonly dispid 202;
    procedure CmdSet(const Param1: WideString); dispid 203;
    property TextIn: WideString readonly dispid 204;
    property LineNbIn: Integer readonly dispid 205;
    property LineIn[Param1: Integer]: WideString readonly dispid 206;
    procedure FilterSet(const Param1: WideString); dispid 207;
    procedure FilterFor(Param1: Integer; const Param2: WideString; const Param3: WideString); dispid 208;
    procedure WaitFor(Param1: Integer; const Param2: WideString; const Param3: WideString); dispid 210;
    procedure WaitReset; dispid 211;
    property WaitStatus: Integer readonly dispid 212;
    procedure InitReset; dispid 213;
    property Path: WideString readonly dispid 214;
    procedure Show(Param1: Integer); dispid 215;
    procedure UserOut(const Param1: WideString; const Param2: WideString); dispid 217;
    procedure PasswOut(const Param1: WideString; const Param2: WideString); dispid 218;
  end;

// *********************************************************************//
// The Class Coserver provides a Create and CreateRemote method to          
// create instances of the default interface Iserver exposed by              
// the CoClass server. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  Coserver = class
    class function Create: Iserver;
    class function CreateRemote(const MachineName: string): Iserver;
  end;

implementation

uses ComObj;

class function Coserver.Create: Iserver;
begin
  Result := CreateComObject(CLASS_server) as Iserver;
end;

class function Coserver.CreateRemote(const MachineName: string): Iserver;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_server) as Iserver;
end;

end.