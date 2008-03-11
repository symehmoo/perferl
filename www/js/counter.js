/*
Author: Robert Hashemian
http://www.hashemian.com/

You can use this code in any manner so long as the author's
name, Web address and this disclaimer is kept intact.
********************************************************
Usage Sample:

<script language="JavaScript">
TargetDate = "12/31/2020 5:00 AM";
BackColor = "palegreen";
ForeColor = "navy";
CountActive = true;
CountStepper = -1;
LeadingZero = true;
DisplayFormat = "%%D%% Days, %%H%% Hours, %%M%% Minutes, %%S%% Seconds.";
FinishMessage = "It is finally here!";
</script>
<script language="JavaScript" src="http://scripts.hashemian.com/js/countdown.js"></script>
*/
var SetTimeOutPeriod;
var TargetDate;
var CountActive;
var CountStepper = 1;
var LeadingZero = true;
var DisplayFormat = "%%M%% Minutes, %%S%% Seconds.";

function calcage(secs, num1, num2) {
  var s = ((Math.floor(secs/num1))%num2).toString();
  if (LeadingZero && s.length < 2)
    s = "0" + s;
  return "<b>" + s + "</b>";
}

function CountBack(secs) {
  if (secs < 0) return;

  var DisplayStr = DisplayFormat.replace(/%%D%%/g, calcage(secs,86400,100000));
  DisplayStr = DisplayStr.replace(/%%H%%/g, calcage(secs,3600,24));
  DisplayStr = DisplayStr.replace(/%%M%%/g, calcage(secs,60,60));
  DisplayStr = DisplayStr.replace(/%%S%%/g, calcage(secs,1,60));

  document.getElementById("cntdwn").innerHTML = DisplayStr;
  if (CountActive)
    setTimeout("CountBack(" + (secs+CountStepper) + ")", SetTimeOutPeriod);
}

function startCounter() {
    TargetDate = new Date();
    document.getElementById("cntdwn").innerHTML = ""
    CountActive = true;
    CountStepper = Math.ceil(CountStepper);
    if (CountStepper == 0)
        CountActive = false;
    SetTimeOutPeriod = (Math.abs(CountStepper) - 1) * 1000 + 990;
    var dthen = new Date(TargetDate);
    var dnow = new Date();
    var ddiff;
    if (CountStepper > 0)
        ddiff = new Date(dnow - dthen);
    else
        ddiff = new Date(dthen - dnow);
    var gsecs = Math.floor(ddiff.valueOf() / 1000);
    CountBack(gsecs);
}

function stopCounter() {
    CountActive = false;
}