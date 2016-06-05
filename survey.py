#!/usr/bin/python
# -*- coding: utf-8 -*-

#the purpose of this script is to run the main experiment loop of the experiment. It is intended primarily for SIGHTED individuals. 
import cgi, cgitb, MySQLdb, sys
from surveyFunc import *
# conn = MySQLdb.connect(host = "localhost", user = "BKIDS", passwd = "BKIDS123", db = "BKIDS")
conn = MySQLdb.connect(host = "localhost", user = "dishes", passwd = "dishes123", db = "dverbs")
cursor = conn.cursor()
form = cgi.FieldStorage()

#set up the page
print "Content-Type: text/html\n\n"
print "<html>"
print "<head>"
try:
    form["subjectName"].value
except: 
    #first time on the page
    print "<title>"
    print "Word Survey"
    print "</title>"
    print "</head>"
    print '<body>'
    logos()
    style() 
    print '<div id="container">'
    print 'Welcome!  Thank you for taking part in our study!  <br><br> '
    welcomeToSurveyForm_d()
    print '<br>'
    print '</div>'
    print '</body>'
    print '</html>'
    sys.exit()
try:
    form["page"].value
except:
    from time import time
    #second time on page
    subject = form["subjectName"].value
    studyName = form["studyName"].value 
    
    all_studies = {'pink':'words_practice', 'blue':'words_TheVerbs','green':'words_TheAdjectives', 'yellow':'words_AnimalCalls', 'red': 'words_AnimalNames', 'copper': 'words_rating', 'silver': 'words_authors', 'gold': 'words_endSurvey'}
    inv_all_studies = {v: k for k, v in all_studies.items()}

    study = all_studies.get(studyName)
    
    if not study:
        study = 'missing'
    trouble = checkStatus(subject, study, cursor)
    if trouble and subject != 'dv_03':
        logos()
        style_2()
        print '<body>'
        print '<div id="container">'
        print "You need to finish the <b>" + inv_all_studies.get(trouble) + "</b> section before starting the next one!<br><br>" 
        welcomeToSurveyForm_d()
        print '</div></body></html>'
        sys.exit()
        
    #check to see if subject exists in the subjects database
    if study == 'words_authors':
        # redirect them to the author recognition info page        
        
        #check in already in database 
        if not findAuthor(subject, cursor):
            instructions_authors(subject)
            sys.exit()
        else: 
            logos()
            style_2()
            print '<body>'
            print '<div id="container">'
            print "<b>You have already completed this section!</b>  <br><br> Please log into the next section instead.  Thank you!<br><br>"
            welcomeToSurveyForm_d()
            print '</div></body></html>'
            sys.exit()
    if study == 'words_endSurvey':
        # redirect them to the exit survey
        logos()        
        style_2()
        print '</head>'
        print '<body>'
        print '<div id="container">'
        print 'You are just one step away from finishing our study! Please click below the continue to the exit survey, where you will be asked some questions about the survey and its content. <br><br>'
        print 'Again, there are no right answers.  Just let us know what you think. <br><br>'
        print '<form action="endSurvey.py" method="post">'
        print '<input type="hidden" name="subject" value="'+subject+'">'
        print '<input type="submit" name="submit" value="Continue"></form>'
        print '</div></body></html>'
        sys.exit()
    if not findSubject(subject, cursor):
        logos()
        style_2()
        print '<body>'
        print '<div id="container">'
        print "We couldn't find that user name -- please try entering it again. (The names are sensitive to spaces and capitalization.)<br><br>"
        welcomeToSurveyForm_d()
        print '</div></body></html>'
        sys.exit()
    #load the verb data for that survey and randomize verbs
    leftOff = findSubjectLast(subject,study,cursor)
    if leftOff == -1:
        #secPageDisp is a variable that determines whether or not someone has already been on the survey. 
        #if secPageDisp == 0: this is their first time on the page. 
        #if secPageDisp == 1: this is *not* the first time on the page. 
        secPageDisp = 0
        surveyVerbs = verbScramble(subject,study,cursor)
        if not surveyVerbs:
            logos()
            style_2()
            print '<body>'
            print '<div id="container">'
            print "We couldn't find that section -- please try entering the name again. (The names are sensitive to spaces and capitalization.)<br><br>"
            welcomeToSurveyForm_d()
            print '</div></body></html>'
            sys.exit()
        putSubIntoDB(subject,study,cursor)
        leftOff = 0
    else:
        leftOff = str(leftOff)
        leftOff = int(leftOff.strip('L(), '))
        if not getVerbs(study, cursor):
            logos()
            style_2()
            print '<body>'
            print '<div id="container">'
            print "We couldn't find that section -- please try entering the name again. (The names are sensitive to spaces and capitalization.)<br><br>"
            welcomeToSurveyForm_d()
            print '</div></body></html>'
            sys.exit()
        surveyVerbs = conductMapping(subject, study, cursor)
        secPageDisp = 1
    #display the directions
    print '<script src="initialScript.js" type="text/javascript"></script>'
    print "<title>"
    print "Word Survey"
    print "</title>"
    print "</head>"
    print '<body onload="initializer();"><div id="container">'
    print '<p>'
    if secPageDisp == 0:
        style_2()
        if study == "words_practice":
            print '<b>Welcome to the first section, ' + subject + '.</b><br>'    
        else:
            print '<b>Welcome to the next section, ' + subject + '.</b><br>'        
        instructions_d(subject,study,surveyVerbs)  
    elif secPageDisp == 1:
        style_2()
        print '<b>Welcome back to our survey, ' + subject + '.</b><br><br>'
        print '<b>You have completed ' + str(leftOff) + ' questions so far!</b> <br>You are %d percent of the way through'%(((leftOff)*100.0)/(len(surveyVerbs))+1) + '. <br><br>If you have forgotten the directions, here they are: <br><br>'
        instructions_d(subject,study,surveyVerbs)  
    print '</p></div>' 
    createForm_2_noButton(subject, study, surveyVerbs, 0, leftOff, time(),1)
    print '</body></html>'
else:
    print '<script src="verbDisplay_2.js" type="text/javascript"></script>'
    print "<title>"
    print "Word Survey"
    print "</title>"
    style_2()
    print "</head>"
    print '<body onload="handleBody();">'
    print '<div id="container">'
    from time import time
    subjectName = form["subjectName"].value
    study = form["study"].value
    startTime = form["startTime"].value
    exec(form["surveyVerbs"].value)
    page = int(form["page"].value)
    flag = int(form["flag"].value)
    timeAns = time() - float(startTime)
    leftOff = int(form["leftOff"].value)
    if page==0 or flag==0:
        pass
    else:
        choice = form["choice"].value
        try:
            putIntoDB(subjectName, study, choice, str(timeAns), surveyVerbs[leftOff-1][0], surveyVerbs[leftOff-1][1], leftOff, cursor)
        except:
            print 'There is a problem! (Error: cDB has failed)  Please contact us cogrady@mail.sdsu.edu to let us know what happened.'
    if page > 10 and page % 200 == 0 and flag == 1:
        style_2()
        print '<div id="container">'
        print "You've done " + str(page) + ' pairs! Nice job.  We recommend taking a small break now. <br><br>'
        print "When you are ready to continue, press the 1 key, <br> or click the 'Done for Now' button to log out for a longer break.<br><br>"
        # response = raw_input('Press any key to continue')
        createForm_2(subjectName, study, surveyVerbs, page, leftOff, time(), 0)        
    #page will start at 0! and represents the verb pair you are currently on (via index)
    else:
        page = page + 1
        leftOff = leftOff + 1
        if leftOff < (len(surveyVerbs)+1):
            #not at the end of the survey
            if page-1 == 0 or flag == 0:
                if study == "words_rating":
                    print '<br><br><br> <b>The first word is:<b> <br>'
                else:                 
                    print '<br><br><br> <b>The first pair is:<b> <br>'
            else:
                if study == "words_rating":
                    print 'On the previous word, you chose ' + str(choice)+ '.<br><br><br> <b>The next word is:<b> <br>'
                else:                 
                    print 'On the previous pair, you chose ' + str(choice)+ '.<br><br><br> <b>The next pair is:<b> <br>'
            
            flag = 1
            print '<br>'
            print '</div>'
            print '<div id="verbcontainer">'
            tWor1 = surveyVerbs[leftOff-1][0]
            tWor2 = surveyVerbs[leftOff-1][1]
            #set the word order.  Assumes that IDs have a XX_num format
            CB = subjectName.split('_')
            CB = int(CB[1])
            CB = CB % 2 #mod 2 
            style_2()
            if '_' in tWor1:
                tWor1 = tWor1[0:tWor1.index('_')] + ' ' +tWor1[tWor1.index('_')+1:]
            if '_' in tWor2:
                tWor2 = tWor2[0:tWor2.index('_')] + ' ' +tWor2[tWor2.index('_')+1:]          
            if study == 'words_rating':  #for the rating familiarity survey
                print tWor1
                print '</div>'
            else:
                if CB==0:
                    print tWor1,' <br>', tWor2
                    print '</div>'
                elif CB==1:
                    print tWor2,' <br>', tWor1
                    print '</div>'
                else:   #no counterbalancing 
                    print tWor1,' <br>', tWor2
                    print '</div>'

            style_2()   
            #make the scale
            boxes()        
            if study == 'words_rating':
                scale_ratings()
            else:
                scale()
        
            #remind them how far they are
            print '<div id="container"><b>You are %d%% of the way through'%(((leftOff-2)*100.0)/(len(surveyVerbs))+1) + '!</b></div>'
            createForm_2(subjectName, study, surveyVerbs, page, leftOff, time(), flag)
        else:
            #at the end of the survey
            logos()
            if study == "words_practice":
                style_2()
                print '<form action="mail_wu.php" method="POST">'
                print '''Thank you for completing the first section in our study!<br><br>
                    Before you go on to the rest of the study, we want to make sure that all of the instructions were clear 
                    and that the study is working on your computer. Please give us your feedback below. 
                    Once we have checked that everything is working properly, we will email you with the rest of the section names. 
                    If there are any problems with the first survey, we will help you resolve them.  
                    Once you hear from us, you can get started on the next section.''' 
                print '<p>Did you understand everything you needed to do (yes/no)? <input type="text" name="understand"> </p>'
                print '<p>Did you use all the numbers on the scale (1 through 7) (yes/no)? <input type="text" name="range"></p>' 
                print '<p>Did you press a specific key for vegetable pairs (yes/no)? <input type="text" name="veggieskey"></p> '
                print '<p>What key did you press for vegetable pairs? <input type="text" name="veggies"></p> '
                print '<input type="hidden" name="subjID" value="'+subjectName+'">'
                print '<p>If you said no to any of these or found them confusing, can you tell us why? <br> <textarea name="whynot" rows="6" cols="25"></textarea><br /></p>'
                print '<p>Any other notes or comments?  Do you need to know anything else before you continue?<br> <textarea name="message" rows="6" cols="25"></textarea><br /></p>'
                print '<input type="submit" value="Send"><input type="reset" value="Clear">'
                print '</form>'
                print "<b>Thank you! Once you click send, you can close the page, or begin another section.  If you don't have any questions, please continue to the next section when you are ready.  If you have questions or are confused, wait for us to contact you.</b>"
                print '</div>'
                print '</body></html>'
            else:
                print '<b>All done!</b><br><br>Thank you for completing this section. You may now close the page, or begin another section.<br><br>'
                welcomeToSurveyForm_d()
                print '</div>'
                print '</body></html>'
