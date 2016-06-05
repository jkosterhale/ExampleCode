#!/usr/bin/python

#prints the initial form. a minor convenience.
#prints the initial form. a minor convenience.
def welcomeToSurveyForm_d():     
    print 'Please enter your User Name and a Section Name.  <br>Remember to do the sections in order.  Thanks!<br><br>'
    print '<form action="survey.py" method="post"><br>'
    print '<table width=100%>'
    #input subject name
    print '<tr><td align="right">Your User Name: </td><td align="left"><input type="text" name="subjectName"></td></tr>'
    print '<tr><td align="right">Section Name: </td><td align="left"><input type="text" name="studyName"></td></tr>'
    print '</table>'
    print '<table width=100%>'
    print '<tr><td align="center"><input type="submit" name="submit" value="Begin!"></td></tr>'
    print '</table>'
    print '<br><br>'
    print 'If you have any questions, <br> email us at cogrady@mail.sdsu.edu or VP at (619) 550-3398.  <br><br>'
    print '</form>'

def instructions_d(subject,study,surveyVerbs):     
    if study == "words_rating":
        print '<br>You have finished rating all of the pairs!  For this next part, we just want to get a sense of how familiar you were with the words.<br><br>'
        print '<b>In this section, you will be rating how familiar you were with the words in the previous sections.</b>'
        print "If you didn't know all of the words, that's no problem.  Some of them are unusual. <br><br>"
        print 'For this part, please rate on a scale of <b>1 to 3 </b> how familiar you with each word <b>in English</b>.<br><br>'
        print "1 means 'don't know that word', <br>  2 means 'recognize the word', <br>  3 means 'definitely know the meaning of that word.'<br><br>"
        print "Work quickly, but carefully.  <b>You may leave the survey at any time by hitting the 'Done for now' button. When you return, you will pick up where you left off.</b><br><br>"
        print '<i><b>Press any key on the keyboard to start. </b></i>'
    else:    
        print "<br><b>In this section, you will be rating the similarity of various words.</b> <br><br>"
        print 'To see these instructions in <b>ASL</b>, click <a href="http://nuna.mit.edu/saxe/verbs2/asl.html" target ="blank">here</a>. <br><br>'
        print "You will see a series of word-pairs. We are asking you to rate them as to how similar in meaning they are on a scale of 1 to 7. To rate the words, simply press that button on your keyboard, and you will be brought to the next pair. In this scale, <br><br>1 represents 'not at all similar', <br>4 represents 'somewhat similar', and <br>7 represents 'very similar'. <br><br>"
        if study == "words_practice":
            print "To give you an idea for what we mean here are some typical ratings form other people: <br><br>'boots and shoes' was rated as a 6 or 7 by most people <br><br> 'boots and stove' was rated as a 1 or 2 by most people <br><br>"
        print "<font color='red'><b> In this section, there is a twist: </b> you will see <b> pairs of vegetables </b> (for example, 'potato, carrot').  When you see these, instead of rating the similarity using 1-7, <b>press the letter v on your keyboard</b>.</font><br><br>"
        print "<b>You may not know all of the words.  That is okay. Just make your best guess</b>. Please do not use a dictionary to look up unfamiliar words during the study.  <br><br>"
        print "There are no 'correct' answers in this section. However, <b>remember that we are interested in similarity in meaning</b>, not in how the words sound when pronounced or how they are spelled. <br><br>" 
        print "We are interested in your opinion - please give us your best estimate and use the full range of the scale during the experiment (using all of the different numbers from 1 through 7). <br><br>" 
        print "<b>As soon as you press one of the keys 1 to 7, you will go on to the next pair. Hit the 'back' key to go back and re-rate the previous word-pair. </b><br><br>"
        print "Work quickly, but carefully.  <b>You may leave the survey at any time by hitting the 'Done for now' button. When you return, you will pick up where you left off.</b><br><br>"
        print '<i><b>Press any key on the keyboard to start. </b></i>'
         
def instructions_authors(subject):
    style_2()
    print '</head>'
    print '<body>'
    print '<div id="container">'

    print '''
    
    You are all done rating words!  The next survey is a little bit different from the surveys you've done so far. 
    Instead of asking you to rate words, we're going to ask you about names of famous people that you might know. 
    <br><br>
    <font color='red'><b>This will be a timed survey. You will have 10 minutes to finish. After 10 minutes the survey will automatically submit itself. </b></font>
    <br><br>Before you begin make sure you are in a quiet place where you can concentrate for 10 minutes. 
    Try to answer as many items as you can within the allotted time. Once you click the Continue button below the timer will begin. Start by reading the survey instructions. Then answer as many questions as you can within the allotted time. If you are unsure, please do not guess because the survey score is penalized for incorrect guesses. 
    <br><br>
    Please click "Continue" to begin the survey
    <br><br>
    '''
    print '<form action="authors.py" method="post"><input type="hidden" name="subjid" value="'+subject+'">'
    print ''' <input type="submit" name="submit" value="Continue"></form>
    </div></body></html>
    '''


def logos():
    print '''
    <br><br><br>
    <table align="center" cellpadding="10">
    <tr><td align="center"><img src="saxelab_logo.png" alt="The Saxe Lab" width="168" height="100"></td>
    <td align="center"><img src="mit.gif" alt="MIT" width="154" height="84"></td></tr></table>    
    <table align="center" cellpadding="10">
    <tr><td align="center"><img src="LLCN.jpg" alt="LLCN" width="622" height="98"></td></tr></table><br>
    '''  

def scale_ratings():
    print '''
    <br><br>
    <div id="container">
    <table frame="box">
        <tr>
            <td align="left">&nbsp; 1</td>
            <td align="center">2</td>
            <td align="right">3 &nbsp;</td>
        </tr>
        <tr>
            <td colspan="3"><div style="float: left" class="ltriangle"></div>
            <div style="float: left" class="line"></div>
            <div style="float: right" class="rtriangle"></div></td>
        </tr>
        <tr>
            <td align="left">&nbsp; Don't Know &nbsp;</td>
            <td align="center">&nbsp; Recognize &nbsp;</td>
            <td align="right">&nbsp; Definitely Know &nbsp;</td>
        </tr>
    </table>
    </div>    
    '''        
    
def scale():
    print '''
    <br><br>
    <div id="container">
    <table frame="box">
        <tr>
            <td align="left">&nbsp; 1</td>
            <td align="center">4</td>
            <td align="right">7 &nbsp;</td>
        </tr>
        <tr>
            <td colspan="3"><div style="float: left" class="ltriangle"></div>
            <div style="float: left" class="line"></div>
            <div style="float: right" class="rtriangle"></div></td>
        </tr>
        <tr>
            <td align="left">&nbsp; Not Similar &nbsp;</td>
            <td align="center">&nbsp; Somewhat Similar &nbsp;</td>
            <td align="right">&nbsp; Very Similar &nbsp;</td>
        </tr>
    </table>
    </div>    

    '''     
    
    

#this function returns True if the subject has been defined, false if it hasn't. 
def findSubject(subject, cursor):
    cursor.execute("SELECT pid FROM subjects WHERE subject=%s",subject)
    findings = cursor.fetchall()
    if findings:
        return True
    else:
        return False
        
        
def findAuthor(subject, cursor):
    cursor.execute("SELECT pid FROM words_authors WHERE subjid=%s",subject)
    findings = cursor.fetchall()
    if findings:
        return True
    else:
        return False        

#this function returns the question the subject was last on when they were last on the study, it will return -1 otherwise. 
def findSubjectLast(subject, study, cursor):
    cursor.execute("SELECT last_quest FROM subjects_and_studies WHERE subject=%s AND study=%s",(subject,study))
    findings = cursor.fetchall()
    if findings:
        return findings
    else:
        return -1

#this function will find the verb list in the database and return it
def getVerbs(study, cursor):
    cursor.execute("SELECT verbs FROM verbListTable WHERE name=%s", study)
    verbs = cursor.fetchall()
    if verbs:
        cursor.execute("SELECT pid FROM verbListTable WHERE name=%s",study)
        cursor.execute("SELECT name FROM verbListTable WHERE pid=%s", str(int(cursor.fetchall()[0][0])))
        if study!=cursor.fetchall()[0][0]:
            return False
        exec(verbs[0][0])
        return verbList
    else:
        return False

#doesTableExist returns false if the table exists (and thus cannot be created), true otherwise
def doesTableExist(table, cursor):
    cursor.execute("select TABLE_NAME from information_schema.tables where table_schema = 'dverbs'")
    tableNamesPre = cursor.fetchall()
    tableNames = map(lambda x: x[0], tableNamesPre)
    if table in tableNames:
        return False
    else:
        return True

#cursorExecutor performs the apparently buggy MySQLdb operations.
def cursorExecutor(string, tuple, cursor):
    commander = string%tuple
    commander2 = 'cursor.execute("'+commander+'")'
    exec(commander2)


#takes the verb list (from getVerbs), returns the scrambled list and stores the STUDY and 
#SCRAMBLED SEQUENCE that the subject is participating in.
def verbScramble(subject, study, cursor):
    import random
    verbList = getVerbs(study, cursor)
    if not verbList:
        return False
    totVerbNum = len(verbList)
    dispSeq = range(totVerbNum)
    random.shuffle(dispSeq)
    surveyVerbs = []
    map(lambda x: surveyVerbs.append(verbList[x]), dispSeq)
    cursor.execute("INSERT INTO subjects_and_studies (subject, study, sequence) VALUES (%s, %s, %s)",(subject, study, str(dispSeq)))
    return surveyVerbs

#obtains the display sequence. 
def getDispSeq(study, subject, cursor):
    cursor.execute("SELECT sequence FROM subjects_and_studies WHERE study=%s AND subject=%s", (study,subject))
    ds = cursor.fetchall()
    if ds:
        exec('dispSeq = '+ds[0][0])
        return dispSeq

#takes the verb list and applies the scrambling function for subjects who are returning to the study. 
def conductMapping(subject, study, cursor):
    verbList = getVerbs(study, cursor)
    dispSeq = getDispSeq(study, subject, cursor)
    surveyVerbs = []
    map(lambda x: surveyVerbs.append(verbList[x]), dispSeq)
    return surveyVerbs
    
    
    
#takes the verb list and applies the scrambling function for subjects who are returning to the study. 
def checkStatus(subject, study, cursor):
    totals = {"words_practice":105, "words_TheVerbs": 1010,  "words_TheAdjectives": 1626, "words_AnimalCalls": 163,  "words_AnimalNames": 146,  "words_rating": 135 }
    for i in range(len(totals)):
        checkstudy = totals.keys()[i]
        if study != checkstudy:
            cursor.execute("SELECT last_quest FROM subjects_and_studies WHERE study=%s AND subject=%s", (checkstudy,subject))
            ds = cursor.fetchall()
            if ds:
                if int(ds[0][0]) == totals.get(checkstudy):
                    trouble = {}
                else:
                    trouble = checkstudy
                    break
            else:
                trouble = {}
    return trouble
            
            
            
    

    
#prin will allow you to print things from within map functions. 
def prin(x):
    print x
    
#defines the style
def style():
    style1 = '''<style type="text/css">
    body {
        font-family:verdana,arial,helvetica,sans-serif;
        font-size:100%;
    }
    #container {
        width:550px;
        margin:40px auto;
    }
    #verbcontainer {
        width:550px;
        margin:40px auto;
    }
    </style>'''
    print style1
    
def style_2():
    style1 = '''    
    #container {
        width:550px;
        margin:20px auto;
    }
    #verbcontainer {
        width:550px;
        margin:10px auto;
        font-size:250%;
        color:blue;
    }
    </style>'''
    print style1


def style_2():
    style1 = '''<style type="text/css">
    body {
        font-family:verdana,arial,helvetica,sans-serif;
        font-size:100%;
    }
    #container {
        width:550px;
        margin:20px auto;
    }
    #verbcontainer {
        width:550px;
        margin:10px auto;
        font-size:300%;
        color:blue;
    }
    </style>'''
    print style1


def boxes():
    boxes1 = '''
    <style type="text/css">
           
    .ltriangle {
        width: 0;
        height: 0;
        border: solid 12px;
        border-color: transparent black transparent transparent;
    }
    .rtriangle {
        width: 0;
        height: 0;
        border: solid 12px;
        border-color: transparent transparent transparent black;
    }
    .line {
        width: 400px;
        height: 6px;
        border-top: solid 9px;
        background: black;
        border-color: white white white white;
    }
  
    </style>
    '''
    print boxes1



#creates the form for the second-to-last part of the survey
def createForm(subjectName, study, surveyVerbs, page, leftOff, startTime):
    #jaws version
    print '<table width=100%><tr><td width=100% align="center">'
    print '<form name="theForm" id="theForm" method="post" action="survey.py">'
    #choice will be detected and filled in by javascript
    print '<input type="hidden" id="choice" name="choice" value="">'
    #these will be filled in ahead of time by python
    print '<input type="hidden" id="subjectName" name="subjectName" value="'+subjectName+'">'
    print '<input type="hidden" id="study" name="study" value="'+study+'">'
    print '<input type="hidden" id="surveyVerbs" name="surveyVerbs" value="surveyVerbs='+str(surveyVerbs)+'">'
    print '<input type="hidden" id="page" name="page" value="'+str(page)+'">'
    print '<input type="hidden" id="startTime" name="startTime" value="'+str(startTime)+'">'
    print '<input type="hidden" id="leftOff" name="leftOff" value="'+str(leftOff)+'">'
    print '</form></td></tr></table>'


#creates the form for the second-to-last part of the survey
def createForm_2(subjectName, study, surveyVerbs, page, leftOff, startTime, flag):
    print '<table width=100%><tr><td width=100% align="center">'
    print '<form name="theForm" id="theForm" method="post" action="survey.py">'
    #choice will be detected and filled in by javascript
    print '<input type="hidden" id="choice" name="choice" value="">'
    #these will be filled in ahead of time by python
    print '<input type="hidden" id="subjectName" name="subjectName" value="'+subjectName+'">'
    print '<input type="hidden" id="study" name="study" value="'+study+'">'
    print '<input type="hidden" id="surveyVerbs" name="surveyVerbs" value="surveyVerbs='+str(surveyVerbs)+'">'
    print '<input type="hidden" id="page" name="page" value="'+str(page)+'">'
    print '<input type="hidden" id="startTime" name="startTime" value="'+str(startTime)+'">'
    print '<input type="hidden" id="leftOff" name="leftOff" value="'+str(leftOff)+'">'
    print '<input type="hidden" id="flag" name="flag" value="'+str(flag)+'">'
    print '</form></td></tr><tr><td align="center">'
    print '<form name="logout" method="post" action="logout_2.html">'
    print '<input type="submit" name="submit" value="Done for now"></form>'
    print '</td></tr></table>'


#creates the first form passed in the sighted survey
#this takes the place of createForm_s because createForm_s prints a "logout" button,
#which was being used by subjects erroneously, thinking it would allow them to begin. 
def createForm_2_noButton(subjectName, study, surveyVerbs, page, leftOff, startTime, flag):
    print '<table width=100%><tr><td width=100% align="center">'
    print '<form name="theForm" id="theForm" method="post" action="survey.py">'
    #choice will be detected and filled in by javascript
    print '<input type="hidden" id="choice" name="choice" value="">'
    #these will be filled in ahead of time by python
    print '<input type="hidden" id="subjectName" name="subjectName" value="'+subjectName+'">'
    print '<input type="hidden" id="study" name="study" value="'+study+'">'
    print '<input type="hidden" id="surveyVerbs" name="surveyVerbs" value="surveyVerbs='+str(surveyVerbs)+'">'
    print '<input type="hidden" id="page" name="page" value="'+str(page)+'">'
    print '<input type="hidden" id="startTime" name="startTime" value="'+str(startTime)+'">'
    print '<input type="hidden" id="leftOff" name="leftOff" value="'+str(leftOff)+'">'
    print '<input type="hidden" id="flag" name="flag" value="'+str(flag)+'">'
    print '</form></td></tr><tr><td align="center">'
    print '</td></tr></table>'

def takeBreak():
    print '<table width=100%><tr><td width=100% align="center">'
    print '<form name="theForm" method="post" action="survey.py">'
    print '<input type="submit" name="submit" value="Continue on!"></form>'
    print '</td></tr></table>'


#prints out the validation script for the participant's demographic information 
def validate_form():
    print '''<script type="text/javascript">
    //Java starts here
    function validate(form){
     if ( form.username.value==null||form.username.value=="")     {alert('Please enter your username.');return false;}
     if ( form.age.value==null||form.age.value=="")               {alert('Please enter your age.');return false;}
     if ( !checkSelect(form.gender) )                             {alert('Please select a gender.');return false;}
     if ( !checkSelect(form.education) )                          {alert('Please select your highest level of education.');return false;}
     if ( form.firstLang.value==null||form.firstLang.value=="")   {alert('Please enter your first language.');return false;}
     if ( form.engAge.value==null||form.engAge.value=="")         {alert('Please enter the age at which you learned english.');return false;}
     return true;
    }</script>'''


#puts our subjects into the databases. 
def putSubIntoDB(subject, study, cursor):
    statement1 = "INSERT INTO "+study+" (subject) VALUES (%s)"
    statement2 = "INSERT INTO "+study + 'RT'+" (subject) VALUES (%s)"
    cursor.execute(statement1,(subject))
    cursor.execute(statement2,(subject))

#handles database stuff
def putIntoDB(subject, study, response, time, verb1, verb2, leftOff, cursor):
    statement1 = 'update '+study+' set '+verb1+'_AND_'+verb2+'="'+response+'" where subject="' + subject +'"'
    statement2 = 'update '+study+'RT set '+verb1+'_AND_'+verb2+'="'+time+'" where subject="' + subject +'"'
    statement3 = 'update subjects_and_studies set last_quest ="'+str(leftOff)+'" where subject="' + subject +'" and study ="' + study + '"'
    cursor.execute(statement1)
    cursor.execute(statement2)
    cursor.execute(statement3)

# puts demographic information into the database
def putDemoIntoDB(username, age, gender, education, firstLang, engAge, cursor):
    statement1 = 'INSERT INTO demographics (subjID, age, gender, education, firstLang, engAge) VALUES (%s, %s, %s, %s, %s, %s)'
    cursor.execute(statement1,(str(username), str(age), str(gender), str(education), str(firstLang), str(engAge)))

# puts user feedback information into the database
def putFeedbackIntoDatabase(username, feedback, cursor):
    statement1 = 'INSERT INTO feedback (username, comment) VALUES (%s, %s)'
    cursor.execute(statement1,(str(username),str(feedback)))
