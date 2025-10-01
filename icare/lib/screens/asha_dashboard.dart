import 'package:flutter/material.dart';

// ---- COLOR PALETTE ----
const Color primaryNavy   = Color(0xFF1E3A8A);
const Color emeraldGreen  = Color(0xFF10B981);
const Color lightBlue     = Color(0xFF3B82F6);
const Color darkNavy      = Color(0xFF0F172A);
const Color goldAccent    = Color(0xFFF59E0B);
const Color softWhite     = Color(0xFFFAFBFC);

// ---- MAIN DASHBOARD ----
class AshaDashboard extends StatefulWidget {
  final bool darkTheme;
  final Function(bool) onThemeToggle;
  const AshaDashboard({required this.darkTheme, required this.onThemeToggle});
  @override
  State<AshaDashboard> createState() => _AshaDashboardState();
}

class _AshaDashboardState extends State<AshaDashboard> {
  int _currentIndex = 0;
  List<Map<String,String>> _visits = [];
  @override
  Widget build(BuildContext context) {
    final isDark = widget.darkTheme;
    final bgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark ? [darkNavy, Color(0xFF1E293B)] : [softWhite, Color(0xFFF1F5F9)],
    );
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Column(children: [
          _AppBar(isDark: isDark, onThemeToggle: widget.onThemeToggle),
          Expanded(child: IndexedStack(
            index: _currentIndex,
            children: [
              VisitListTab(visits: _visits, onAddVisit: (v)=>setState(()=>_visits.add(v))),
              CommunityTab(),
              NotesTab(),
              ProfileTab(darkTheme: widget.darkTheme, onThemeToggle: widget.onThemeToggle),
            ],
          )),
        ]),
      ),
      bottomNavigationBar: _BottomNav(
        isDark: isDark,
        currentIndex: _currentIndex,
        onTap: (i)=>setState(()=>_currentIndex=i),
      ),
    );
  }
}

// ---- APP BAR ----
class _AppBar extends StatelessWidget {
  final bool isDark;
  final void Function(bool) onThemeToggle;
  const _AppBar({required this.isDark, required this.onThemeToggle});
  @override Widget build(BuildContext c) => Container(
    padding: EdgeInsets.fromLTRB(20,50,20,25),
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft,end: Alignment.bottomRight,colors:[primaryNavy,emeraldGreen]),
      borderRadius: BorderRadius.vertical(bottom:Radius.circular(30)),
      boxShadow:[BoxShadow(color:primaryNavy.withOpacity(0.3),blurRadius:20,offset:Offset(0,10))]
    ),
    child: Row(children:[
      Icon(Icons.star_purple500_sharp,color:Colors.white,size:32),
      SizedBox(width:8),
      Expanded(child:Text("ASHA Worker",style:TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.bold))),
      IconButton(
        icon:Icon(isDark?Icons.light_mode:Icons.dark_mode,color:Colors.white),
        onPressed:()=>onThemeToggle(!isDark),
      )
    ]),
  );
}

// ---- BOTTOM NAV ----
class _BottomNav extends StatelessWidget {
  final bool isDark; final int currentIndex; final void Function(int) onTap;
  const _BottomNav({required this.isDark,required this.currentIndex,required this.onTap});
  @override Widget build(BuildContext c)=>Container(
    margin:EdgeInsets.all(20),
    decoration:BoxDecoration(
      borderRadius:BorderRadius.circular(25),
      color:isDark?darkNavy.withOpacity(0.95):Colors.white,
      boxShadow:[BoxShadow(color:Colors.black12,blurRadius:15,offset:Offset(0,10))]
    ),
    child: BottomNavigationBar(
      currentIndex:currentIndex,backgroundColor:Colors.transparent,elevation:0,
      selectedItemColor:emeraldGreen,unselectedItemColor:isDark?Colors.grey[400]:Colors.grey[600],
      items:[
        BottomNavigationBarItem(icon:Icon(Icons.assignment),label:"Visits"),
        BottomNavigationBarItem(icon:Icon(Icons.people),label:"Community"),
        BottomNavigationBarItem(icon:Icon(Icons.note),label:"Notes"),
        BottomNavigationBarItem(icon:Icon(Icons.person),label:"Profile"),
      ],
      onTap:onTap,
    ),
  );
}

// ---- VISIT TAB ----
class VisitListTab extends StatelessWidget {
  final List<Map<String,String>> visits;
  final Function(Map<String,String>) onAddVisit;
  const VisitListTab({required this.visits,required this.onAddVisit});
  @override Widget build(BuildContext c){
    final isDark=Theme.of(c).brightness==Brightness.dark;
    return Scaffold(
      backgroundColor:Colors.transparent,
      floatingActionButton:FloatingActionButton.extended(
        onPressed:()async{
          final r=await showDialog<Map<String,String>>(context:c,builder:(_)=>AddVisitDialog());
          if(r!=null)onAddVisit(r);
        },
        icon:Icon(Icons.add),label:Text("Add Visit"),backgroundColor:emeraldGreen
      ),
      body:Padding(padding:EdgeInsets.all(20),child:Column(children:[
        _VisitStats(count:visits.length),
        SizedBox(height:20),
        Expanded(child:
          visits.isEmpty
            ? Center(child:Text("No visits scheduled",style:TextStyle(color:isDark?Colors.white54:Colors.black54)))
            :ListView.builder(itemCount:visits.length,itemBuilder:(_,i)=>Card(
              color:isDark?darkNavy.withOpacity(0.7):Colors.white,
              margin:EdgeInsets.only(bottom:12),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),
              child:ListTile(
                title:Text(visits[i]['name']!,style:TextStyle(color:isDark?Colors.white:Colors.black)),
                subtitle:Text("${visits[i]['date']} • ${visits[i]['time']}",style:TextStyle(color:isDark?Colors.white70:Colors.black54)),
              )
            ))
        )
      ])),
    );
  }
}

class _VisitStats extends StatelessWidget {
  final int count;
  const _VisitStats({required this.count});
  @override Widget build(BuildContext c)=>Container(
    width:double.infinity,padding:EdgeInsets.all(16),
    decoration:BoxDecoration(
      gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[emeraldGreen,lightBlue]),
      borderRadius:BorderRadius.circular(12)
    ),
    child:Row(children:[
      Icon(Icons.medical_services,color:Colors.white,size:28),
      SizedBox(width:12),
      Text("$count Visits",style:TextStyle(color:Colors.white,fontSize:20)),
    ]),
  );
}

// ---- VISIT DIALOG ----
class AddVisitDialog extends StatefulWidget {
  @override State<AddVisitDialog> createState()=>_AddVisitDialogState();
}
class _AddVisitDialogState extends State<AddVisitDialog>{
  final _name=TextEditingController();
  final _date=TextEditingController();
  final _time=TextEditingController();
  final _notes=TextEditingController();
  @override Widget build(BuildContext c){
    final isDark=Theme.of(c).brightness==Brightness.dark;
    return Dialog(backgroundColor:Colors.transparent,child:Container(
      padding:EdgeInsets.all(20),decoration:BoxDecoration(color:isDark?darkNavy:Colors.white,borderRadius:BorderRadius.circular(12)),
      child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
        Text("Visit Details",style:TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:isDark?Colors.white:Colors.black)),
        SizedBox(height:12),
        TextField(controller:_name,decoration:InputDecoration(labelText:"Patient/Place")),
        SizedBox(height:8),
        TextField(controller:_date,decoration:InputDecoration(labelText:"Date (YYYY-MM-DD)")),
        SizedBox(height:8),
        TextField(controller:_time,decoration:InputDecoration(labelText:"Time (HH:MM)")),
        SizedBox(height:8),
        TextField(controller:_notes,maxLines:3,decoration:InputDecoration(labelText:"Notes")),
        SizedBox(height:16),
        Row(children:[
          Expanded(child:TextButton(onPressed:()=>Navigator.pop(c),child:Text("Cancel"))),
          SizedBox(width:12),
          Expanded(child:ElevatedButton(onPressed:()=>Navigator.pop(c,{
            'name':_name.text,'date':_date.text,'time':_time.text,'notes':_notes.text
          }),child:Text("Add")))
        ])
      ]))
    ));
  }
}

// ---- COMMUNITY, NOTES, PROFILE TABS ----
// Implement CommunityTab, NotesTab, ProfileTab similarly with detailed dialogs
// using the patterns above.


// COMMUNITY TAB
class CommunityTab extends StatefulWidget {
  @override State<CommunityTab> createState()=>_CommunityTabState();
}
class _CommunityTabState extends State<CommunityTab>{
  final _titleController=TextEditingController();
  final _descController=TextEditingController();
  final List<Map<String,String>> _submissions=[];
  void _submitIssue(){
    if(_titleController.text.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Please enter a title!"),backgroundColor:Colors.red[400],behavior:SnackBarBehavior.floating));return;
    }
    setState(()=>_submissions.insert(0,{
      'title':_titleController.text.trim(),
      'desc':_descController.text.trim(),
      'time':DateTime.now().toLocal().toString().substring(0,16),
    }));
    _titleController.clear();
    _descController.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Issue reported!"),backgroundColor:emeraldGreen,behavior:SnackBarBehavior.floating));
  }
  @override Widget build(BuildContext c){
    final isDark=Theme.of(context).brightness==Brightness.dark;
    return Padding(padding:EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text("Report Community Issue",style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:isDark?Colors.grey[100]:Colors.grey[800])),
      SizedBox(height:12),
      TextField(controller:_titleController,decoration:InputDecoration(labelText:"Issue Title",border:OutlineInputBorder(borderRadius:BorderRadius.circular(14)))),
      SizedBox(height:12),
      TextField(controller:_descController,minLines:2,maxLines:5,decoration:InputDecoration(labelText:"Description",border:OutlineInputBorder(borderRadius:BorderRadius.circular(14)))),
      SizedBox(height:12),
      ElevatedButton.icon(onPressed:_submitIssue,icon:Icon(Icons.send),label:Text("Submit Issue"),style:ElevatedButton.styleFrom(backgroundColor:primaryNavy,shape:StadiumBorder(),minimumSize:Size(double.infinity,44))),
      Divider(height:40),
      Text("Your Reported Issues",style:TextStyle(fontSize:19,fontWeight:FontWeight.w500)),
      SizedBox(height:10),
      Expanded(child:_submissions.isEmpty?Center(child:Text("No issues submitted yet.",style:TextStyle(color:Colors.grey, fontSize:16))):ListView.builder(itemCount:_submissions.length,itemBuilder:(cx,i){
        final issue=_submissions[i];
        return Card(margin:EdgeInsets.symmetric(vertical:6),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14)),child:ListTile(
          title:Text(issue['title']!,style:TextStyle(fontWeight:FontWeight.bold)),
          subtitle:Text(issue['desc']!.isEmpty?"No description":issue['desc']!),
          trailing:Text(issue['time']!,style:TextStyle(fontSize:12,color:Colors.grey)),
        ));
      }))
    ]));
  }
}

// NOTES TAB
class NotesTab extends StatefulWidget {
  @override State<NotesTab> createState()=>_NotesTabState();
}
class _NotesTabState extends State<NotesTab>{
  List<String> _notes=[];
  void _addNote(String n)=>setState(()=>_notes.insert(0,n));
  void _editNote(int i,String nt)=>setState(()=>_notes[i]=nt);
  void _deleteNote(int i)=>setState(()=>_notes.removeAt(i));
  Future<void> _showNoteDialog({String? initialText,required Function(String) onValue})async{
    final c=TextEditingController(text:initialText??"");
    final r=await showDialog<String>(context:context,builder:(ctx){
      final isDark=Theme.of(ctx).brightness==Brightness.dark;
      return Dialog(backgroundColor:Colors.transparent,child:Container(
        padding:EdgeInsets.all(24),decoration:BoxDecoration(color:isDark?darkNavy:Colors.white,borderRadius:BorderRadius.circular(20),boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.1),blurRadius:20,offset:Offset(0,10))]),
        child:Column(mainAxisSize:MainAxisSize.min,children:[
          Container(padding:EdgeInsets.all(15),decoration:BoxDecoration(color:lightBlue.withOpacity(0.1),borderRadius:BorderRadius.circular(15)),child:Icon(Icons.note_add,color:lightBlue,size:30)),
          SizedBox(height:20),
          Text(initialText==null?"Add Note":"Edit Note",style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:isDark?Colors.grey[100]:Colors.grey[800])),
          SizedBox(height:20),
          TextField(controller:c,autofocus:true,maxLines:4,decoration:InputDecoration(labelText:"Note Content",hintText:"Enter your note here...",border:OutlineInputBorder(borderRadius:BorderRadius.circular(15)),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(15),borderSide:BorderSide(color:lightBlue,width:2)))),
          SizedBox(height:24),
          Row(children:[
            Expanded(child:TextButton(onPressed:()=>Navigator.pop(ctx),child:Text("Cancel"),style:TextButton.styleFrom(foregroundColor:Colors.grey[600],padding:EdgeInsets.symmetric(vertical:15)))),
            SizedBox(width:12),
            Expanded(child:ElevatedButton(onPressed:()=>Navigator.pop(ctx,c.text),child:Text(initialText==null?"Add":"Save"),style:ElevatedButton.styleFrom(backgroundColor:lightBlue,foregroundColor:Colors.white,padding:EdgeInsets.symmetric(vertical:15),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)))))
          ])
        ])
      ));
    });
    if(r!=null&&r.trim().isNotEmpty)onValue(r.trim());
  }
  @override Widget build(BuildContext context){
    final isDark=Theme.of(context).brightness==Brightness.dark;
    return Scaffold(
      backgroundColor:Colors.transparent,
      floatingActionButton:FloatingActionButton.extended(onPressed:()=>_showNoteDialog(onValue:_addNote),icon:Icon(Icons.add),label:Text("Add Note"),backgroundColor:lightBlue),
      body:Padding(padding:EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Row(children:[
          Container(padding:EdgeInsets.all(12),decoration:BoxDecoration(color:lightBlue.withOpacity(0.1),borderRadius:BorderRadius.circular(12)),child:Icon(Icons.notes,color:lightBlue,size:24)),
          SizedBox(width:15),
          Text("My Notes",style:TextStyle(fontSize:24,fontWeight:FontWeight.bold,color:isDark?Colors.grey[100]:Colors.grey[800])),
          Spacer(),
          Container(padding:EdgeInsets.symmetric(horizontal:12,vertical:6),decoration:BoxDecoration(color:lightBlue.withOpacity(0.1),borderRadius:BorderRadius.circular(20)),child:Text("${_notes.length}",style:TextStyle(color:lightBlue,fontWeight:FontWeight.bold))),
        ]),
        SizedBox(height:20),
        Expanded(child:_notes.isEmpty?Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
          Container(padding:EdgeInsets.all(20),decoration:BoxDecoration(color:lightBlue.withOpacity(0.1),borderRadius:BorderRadius.circular(20)),child:Icon(Icons.note_outlined,size:60,color:lightBlue)),
          SizedBox(height:20),
          Text("No notes yet",style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:isDark?Colors.grey[300]:Colors.grey[700])),
          SizedBox(height:8),
          Text("Create your first note to get started",style:TextStyle(fontSize:16,color:isDark?Colors.grey[400]:Colors.grey[600])),
        ])):ListView.builder(itemCount:_notes.length,itemBuilder:(c,i)=>Container(margin:EdgeInsets.only(bottom:15),padding:EdgeInsets.all(16),decoration:BoxDecoration(color:isDark?darkNavy.withOpacity(0.7):Colors.white,borderRadius:BorderRadius.circular(15),boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.05),blurRadius:10,offset:Offset(0,5))]),child:Row(children:[
          Expanded(child:Text(_notes[i],style:TextStyle(fontSize:16,color:isDark?Colors.grey[200]:Colors.grey[800]))),
          IconButton(icon:Icon(Icons.edit,color:lightBlue,size:20),onPressed:()=>_showNoteDialog(initialText:_notes[i],onValue:(nt)=>_editNote(i,nt))),
          IconButton(icon:Icon(Icons.delete,color:Colors.red[400],size:20),onPressed:()=>_deleteNote(i)),
        ]))))
      ]))
    );
  }
}

// PROFILE TAB
class ProfileTab extends StatelessWidget {
  final bool darkTheme;
  final Function(bool) onThemeToggle;
  ProfileTab({required this.darkTheme,required this.onThemeToggle});
  @override Widget build(BuildContext context){
    final isDark=darkTheme;
    return Padding(padding:EdgeInsets.all(20),child:Column(children:[
      Container(width:double.infinity,padding:EdgeInsets.all(24),decoration:BoxDecoration(gradient:LinearGradient(colors:[primaryNavy,emeraldGreen]),borderRadius:BorderRadius.circular(25),boxShadow:[BoxShadow(color:primaryNavy.withOpacity(0.3),blurRadius:20,offset:Offset(0,10))]),child:Column(children:[
        Container(width:80,height:80,decoration:BoxDecoration(color:Colors.white.withOpacity(0.2),borderRadius:BorderRadius.circular(25)),child:Icon(Icons.person,size:40,color:Colors.white)),
        SizedBox(height:16),
        Text("ASHA Worker",style:TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.bold)),
        Text("asha.worker@example.com",style:TextStyle(color:Colors.white70,fontSize:16)),
      ])),
      SizedBox(height:24),
      _profileItem(Icons.person_outline,"Edit Profile","Update your info",primaryNavy,()=>_showComingSoon(context)),
      _profileItem(Icons.notifications_outlined,"Notifications","Manage alerts",emeraldGreen,()=>_showComingSoon(context)),
      _themeSwitch(context,isDark),
      _profileItem(Icons.help_outline,"Help & Support","Get assistance",lightBlue,()=>_showComingSoon(context)),
      _profileItem(Icons.logout,"Sign Out","Log out",Colors.red[400]!,()=>Navigator.of(context).pushReplacementNamed('/login')),
    ]));
  }

  Widget _profileItem(IconData icon,String title,String sub,Color color,VoidCallback onTap)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(15),child:Container(padding:EdgeInsets.symmetric(horizontal:20,vertical:16),child:Row(children:[
    Container(padding:EdgeInsets.all(10),decoration:BoxDecoration(color:color.withOpacity(0.1),borderRadius:BorderRadius.circular(12)),child:Icon(icon,color:color,size:24)),
    SizedBox(width:16),
    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(title,style:TextStyle(fontSize:16,fontWeight:FontWeight.w600)),
      Text(sub,style:TextStyle(fontSize:13,color:Colors.grey[600])),
    ])),
    Icon(Icons.arrow_forward_ios,size:16,color:Colors.grey[400]),
  ])));

  Widget _themeSwitch(BuildContext c,bool isDark)=>Container(padding:EdgeInsets.symmetric(horizontal:20,vertical:16),child:Row(children:[
    Container(padding:EdgeInsets.all(10),decoration:BoxDecoration(color:goldAccent.withOpacity(0.1),borderRadius:BorderRadius.circular(12)),child:Icon(Icons.dark_mode_outlined,color:goldAccent,size:24)),
    SizedBox(width:16),
    Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text("Dark Theme",style:TextStyle(fontSize:16,fontWeight:FontWeight.w600,color:isDark?Colors.grey[200]:Colors.grey[800])),
      Text("Toggle light/dark mode",style:TextStyle(fontSize:13,color:isDark?Colors.grey[400]:Colors.grey[600])),
    ])),
    Switch(value:isDark,onChanged:onThemeToggle, activeColor:goldAccent),
  ]));

  void _showComingSoon(BuildContext c)=>ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text("Coming Soon!"),behavior:SnackBarBehavior.floating));
}
