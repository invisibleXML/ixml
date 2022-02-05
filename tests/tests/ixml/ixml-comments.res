{❌}ixml{❌}:{❌}S{❌},{❌}rule{❌}+{❌}S{❌},{❌}S{❌}.{❌}
{❌}-{❌}S{❌}:{❌}({❌}whitespace{❌};{❌}comment{❌}){❌}*{❌}.{❌}
{❌}-{❌}whitespace{❌}:{❌}-{❌}[{❌}Zs{❌}]{❌};{❌}tab{❌};{❌}lf{❌};{❌}cr{❌}.{❌}
{❌}-{❌}tab{❌}:{❌}-{❌}#9{❌}.{❌}
{❌}-{❌}lf{❌}:{❌}-{❌}#a{❌}.{❌}
{❌}-{❌}cr{❌}:{❌}-{❌}#d{❌}.{❌}
{❌}comment{❌}:{❌}-{❌}"{"{❌},{❌}({❌}cchar{❌};{❌}comment{❌}){❌}*{❌},{❌}-{❌}"}"{❌}.{❌}
{❌}-{❌}cchar{❌}:{❌}~{❌}[{❌}"{}"{❌}]{❌}.{❌}
{❌}rule{❌}:{❌}({❌}mark{❌},{❌}S{❌}){❌}?{❌},{❌}name{❌},{❌}S{❌},{❌}[{❌}"=:"{❌}]{❌},{❌}S{❌},{❌}-{❌}alts{❌},{❌}"."{❌}.{❌}
{❌}@{❌}mark{❌}:{❌}[{❌}"@^-"{❌}]{❌}.{❌}
{❌}alts{❌}:{❌}alt{❌}+{❌}({❌}[{❌}";|"{❌}]{❌},{❌}S{❌}){❌}.{❌}
{❌}alt{❌}:{❌}term{❌}*{❌}({❌}","{❌},{❌}S{❌}){❌}.{❌}
{❌}-{❌}term{❌}:{❌}factor{❌};{❌}
{❌}{❌}{❌}{❌}{❌}option{❌};{❌}
{❌}{❌}{❌}{❌}{❌}repeat0{❌};{❌}
{❌}{❌}{❌}{❌}{❌}repeat1{❌}.{❌}
{❌}-{❌}factor{❌}:{❌}terminal{❌};{❌}
{❌}{❌}{❌}{❌}{❌}{❌}nonterminal{❌};{❌}
{❌}{❌}{❌}{❌}{❌}{❌}"("{❌},{❌}S{❌},{❌}alts{❌},{❌}")"{❌},{❌}S{❌}.{❌}
{❌}repeat0{❌}:{❌}factor{❌},{❌}"*"{❌},{❌}S{❌},{❌}sep{❌}?{❌}.{❌}
{❌}repeat1{❌}:{❌}factor{❌},{❌}"+"{❌},{❌}S{❌},{❌}sep{❌}?{❌}.{❌}
{❌}option{❌}:{❌}factor{❌},{❌}"?"{❌},{❌}S{❌}.{❌}
{❌}sep{❌}:{❌}factor{❌}.{❌}
{❌}nonterminal{❌}:{❌}({❌}mark{❌},{❌}S{❌}){❌}?{❌},{❌}name{❌},{❌}S{❌}.{❌}
{❌}-{❌}terminal{❌}:{❌}literal{❌};{❌}
{❌}{❌}{❌}{❌}{❌}{❌}{❌}charset{❌}.{❌}
{❌}literal{❌}:{❌}quoted{❌};{❌}
{❌}{❌}{❌}{❌}{❌}{❌}encoded{❌}.{❌}
{❌}-{❌}quoted{❌}:{❌}({❌}tmark{❌},{❌}S{❌}){❌}?{❌},{❌}-{❌}string{❌}.{❌}
{❌}@{❌}name{❌}:{❌}namestart{❌},{❌}namefollower{❌}*{❌}.{❌}
{❌}-{❌}namestart{❌}:{❌}[{❌}"_"{❌};{❌}Ll{❌};{❌}Lu{❌};{❌}Lm{❌};{❌}Lt{❌};{❌}Lo{❌}]{❌}.{❌}
{❌}-{❌}namefollower{❌}:{❌}namestart{❌};{❌}[{❌}"-.·‿⁀"{❌};{❌}Nd{❌};{❌}Mn{❌}]{❌}.{❌}
{❌}@{❌}tmark{❌}:{❌}[{❌}"^-"{❌}]{❌}.{❌}
{❌}string{❌}:{❌}-{❌}'"'{❌},{❌}dstring{❌},{❌}-{❌}'"'{❌},{❌}S{❌};{❌}
{❌}-{❌}"'"{❌},{❌}sstring{❌},{❌}-{❌}"'"{❌},{❌}S{❌}.{❌}
{❌}@{❌}dstring{❌}:{❌}dchar{❌}+{❌}.{❌}
{❌}@{❌}sstring{❌}:{❌}schar{❌}+{❌}.{❌}
{❌}dchar{❌}:{❌}~{❌}[{❌}'"'{❌}]{❌};{❌}
{❌}{❌}{❌}{❌}{❌}'"'{❌},{❌}-{❌}'"'{❌}.{❌}{{❌}all{❌}characters{❌},{❌}quotes{❌}must{❌}be{❌}doubled{❌}}
{❌}schar{❌}:{❌}~{❌}[{❌}"'"{❌}]{❌};{❌}
{❌}{❌}{❌}{❌}{❌}"'"{❌},{❌}-{❌}"'"{❌}.{❌}{{❌}all{❌}characters{❌},{❌}quotes{❌}must{❌}be{❌}doubled{❌}}
{❌}-{❌}encoded{❌}:{❌}({❌}tmark{❌},{❌}S{❌}){❌}?{❌},{❌}-{❌}"#"{❌},{❌}@{❌}hex{❌},{❌}S{❌}.{❌}
{❌}hex{❌}:{❌}[{❌}"0"{❌}-{❌}"9"{❌};{❌}"a"{❌}-{❌}"f"{❌};{❌}"A"{❌}-{❌}"F"{❌}]{❌}+{❌}.{❌}
{❌}-{❌}charset{❌}:{❌}inclusion{❌};{❌}
{❌}{❌}{❌}{❌}{❌}{❌}{❌}exclusion{❌}.{❌}
{❌}inclusion{❌}:{❌}({❌}tmark{❌},{❌}S{❌}){❌}?{❌},{❌}set{❌}.{❌}
{❌}exclusion{❌}:{❌}({❌}tmark{❌},{❌}S{❌}){❌}?{❌},{❌}"~"{❌},{❌}S{❌},{❌}set{❌}.{❌}
{❌}-{❌}set{❌}:{❌}"["{❌},{❌}S{❌},{❌}member{❌}*{❌}({❌}[{❌}";|"{❌}]{❌},{❌}S{❌}){❌},{❌}"]"{❌},{❌}S{❌}.{❌}
{❌}-{❌}member{❌}:{❌}literal{❌};{❌}
{❌}{❌}{❌}{❌}{❌}{❌}range{❌};{❌}
{❌}{❌}{❌}{❌}{❌}{❌}class{❌}.{❌}
{❌}range{❌}:{❌}from{❌},{❌}"-"{❌},{❌}S{❌},{❌}to{❌}.{❌}
{❌}@{❌}from{❌}:{❌}character{❌}.{❌}
{❌}@{❌}to{❌}:{❌}character{❌}.{❌}
{❌}-{❌}character{❌}:{❌}-{❌}'"'{❌},{❌}dchar{❌},{❌}-{❌}'"'{❌},{❌}S{❌};{❌}
{❌}-{❌}"'"{❌},{❌}schar{❌},{❌}-{❌}"'"{❌},{❌}S{❌};{❌}
{❌}"#"{❌},{❌}hex{❌},{❌}S{❌}.{❌}
{❌}class{❌}:{❌}@{❌}code{❌},{❌}S{❌}.{❌}
{❌}code{❌}:{❌}letter{❌},{❌}letter{❌}.{❌}
{❌}-{❌}letter{❌}:{❌}[{❌}"a"{❌}-{❌}"z"{❌};{❌}"A"{❌}-{❌}"Z"{❌}]{❌}.{❌}
#
{❌}ixml{❌}:{❌}S{❌},{❌}rule{❌}+{❌}S{❌},{❌}S{❌}.{❌}
{❌}-{❌}S{❌}:{❌}({❌}whitespace{❌};{❌}comment{❌}){❌}*{❌}.{❌}
{❌}-{❌}whitespace{❌}:{❌}-{❌}[{❌}Zs{❌}]{❌};{❌}tab{❌};{❌}lf{❌};{❌}cr{❌}.{❌}
{❌}-{❌}tab{❌}:{❌}-{❌}#9{❌}.{❌}
{❌}-{❌}lf{❌}:{❌}-{❌}#a{❌}.{❌}
{❌}-{❌}cr{❌}:{❌}-{❌}#d{❌}.{❌}
{❌}comment{❌}:{❌}-{❌}"{"{❌},{❌}({❌}cchar{❌};{❌}comment{❌}){❌}*{❌},{❌}-{❌}"}"{❌}.{❌}
{❌}-{❌}cchar{❌}:{❌}~{❌}[{❌}"{}"{❌}]{❌}.{❌}
{❌}rule{❌}:{❌}({❌}mark{❌},{❌}S{❌}){❌}?{❌},{❌}name{❌},{❌}S{❌},{❌}[{❌}"=:"{❌}]{❌},{❌}S{❌},{❌}-{❌}alts{❌},{❌}"."{❌}.{❌}
{❌}@{❌}mark{❌}:{❌}[{❌}"@^-"{❌}]{❌}.{❌}
{❌}alts{❌}:{❌}alt{❌}+{❌}({❌}[{❌}";|"{❌}]{❌},{❌}S{❌}){❌}.{❌}
{❌}alt{❌}:{❌}term{❌}*{❌}({❌}","{❌},{❌}S{❌}){❌}.{❌}
{❌}-{❌}term{❌}:{❌}factor{❌};{❌}
{❌}{❌}{❌}{❌}{❌}option{❌};{❌}
{❌}{❌}{❌}{❌}{❌}repeat0{❌};{❌}
{❌}{❌}{❌}{❌}{❌}repeat1{❌}.{❌}
{❌}-{❌}factor{❌}:{❌}terminal{❌};{❌}
{❌}{❌}{❌}{❌}{❌}{❌}nonterminal{❌};{❌}
{❌}{❌}{❌}{❌}{❌}{❌}"("{❌},{❌}S{❌},{❌}alts{❌},{❌}")"{❌},{❌}S{❌}.{❌}
{❌}repeat0{❌}:{❌}factor{❌},{❌}"*"{❌},{❌}S{❌},{❌}sep{❌}?{❌}.{❌}
{❌}repeat1{❌}:{❌}factor{❌},{❌}"+"{❌},{❌}S{❌},{❌}sep{❌}?{❌}.{❌}
{❌}option{❌}:{❌}factor{❌},{❌}"?"{❌},{❌}S{❌}.{❌}
{❌}sep{❌}:{❌}factor{❌}.{❌}
{❌}nonterminal{❌}:{❌}({❌}mark{❌},{❌}S{❌}){❌}?{❌},{❌}name{❌},{❌}S{❌}.{❌}
{❌}-{❌}terminal{❌}:{❌}literal{❌};{❌}
{❌}{❌}{❌}{❌}{❌}{❌}{❌}charset{❌}.{❌}
{❌}literal{❌}:{❌}quoted{❌};{❌}
{❌}{❌}{❌}{❌}{❌}{❌}encoded{❌}.{❌}
{❌}-{❌}quoted{❌}:{❌}({❌}tmark{❌},{❌}S{❌}){❌}?{❌},{❌}-{❌}string{❌}.{❌}
{❌}@{❌}name{❌}:{❌}namestart{❌},{❌}namefollower{❌}*{❌}.{❌}
{❌}-{❌}namestart{❌}:{❌}[{❌}"_"{❌};{❌}Ll{❌};{❌}Lu{❌};{❌}Lm{❌};{❌}Lt{❌};{❌}Lo{❌}]{❌}.{❌}
{❌}-{❌}namefollower{❌}:{❌}namestart{❌};{❌}[{❌}"-.·‿⁀"{❌};{❌}Nd{❌};{❌}Mn{❌}]{❌}.{❌}
{❌}@{❌}tmark{❌}:{❌}[{❌}"^-"{❌}]{❌}.{❌}
{❌}string{❌}:{❌}-{❌}'"'{❌},{❌}dstring{❌},{❌}-{❌}'"'{❌},{❌}S{❌};{❌}
{❌}-{❌}"'"{❌},{❌}sstring{❌},{❌}-{❌}"'"{❌},{❌}S{❌}.{❌}
{❌}@{❌}dstring{❌}:{❌}dchar{❌}+{❌}.{❌}
{❌}@{❌}sstring{❌}:{❌}schar{❌}+{❌}.{❌}
{❌}dchar{❌}:{❌}~{❌}[{❌}'"'{❌}]{❌};{❌}
{❌}{❌}{❌}{❌}{❌}'"'{❌},{❌}-{❌}'"'{❌}.{❌}{{❌}all{❌}characters{❌},{❌}quotes{❌}must{❌}be{❌}doubled{❌}}
{❌}schar{❌}:{❌}~{❌}[{❌}"'"{❌}]{❌};{❌}
{❌}{❌}{❌}{❌}{❌}"'"{❌},{❌}-{❌}"'"{❌}.{❌}{{❌}all{❌}characters{❌},{❌}quotes{❌}must{❌}be{❌}doubled{❌}}
{❌}-{❌}encoded{❌}:{❌}({❌}tmark{❌},{❌}S{❌}){❌}?{❌},{❌}-{❌}"#"{❌},{❌}@{❌}hex{❌},{❌}S{❌}.{❌}
{❌}hex{❌}:{❌}[{❌}"0"{❌}-{❌}"9"{❌};{❌}"a"{❌}-{❌}"f"{❌};{❌}"A"{❌}-{❌}"F"{❌}]{❌}+{❌}.{❌}
{❌}-{❌}charset{❌}:{❌}inclusion{❌};{❌}
{❌}{❌}{❌}{❌}{❌}{❌}{❌}exclusion{❌}.{❌}
{❌}inclusion{❌}:{❌}({❌}tmark{❌},{❌}S{❌}){❌}?{❌},{❌}set{❌}.{❌}
{❌}exclusion{❌}:{❌}({❌}tmark{❌},{❌}S{❌}){❌}?{❌},{❌}"~"{❌},{❌}S{❌},{❌}set{❌}.{❌}
{❌}-{❌}set{❌}:{❌}"["{❌},{❌}S{❌},{❌}member{❌}*{❌}({❌}[{❌}";|"{❌}]{❌},{❌}S{❌}){❌},{❌}"]"{❌},{❌}S{❌}.{❌}
{❌}-{❌}member{❌}:{❌}literal{❌};{❌}
{❌}{❌}{❌}{❌}{❌}{❌}range{❌};{❌}
{❌}{❌}{❌}{❌}{❌}{❌}class{❌}.{❌}
{❌}range{❌}:{❌}from{❌},{❌}"-"{❌},{❌}S{❌},{❌}to{❌}.{❌}
{❌}@{❌}from{❌}:{❌}character{❌}.{❌}
{❌}@{❌}to{❌}:{❌}character{❌}.{❌}
{❌}-{❌}character{❌}:{❌}-{❌}'"'{❌},{❌}dchar{❌},{❌}-{❌}'"'{❌},{❌}S{❌};{❌}
{❌}-{❌}"'"{❌},{❌}schar{❌},{❌}-{❌}"'"{❌},{❌}S{❌};{❌}
{❌}"#"{❌},{❌}hex{❌},{❌}S{❌}.{❌}
{❌}class{❌}:{❌}@{❌}code{❌},{❌}S{❌}.{❌}
{❌}code{❌}:{❌}letter{❌},{❌}letter{❌}.{❌}
{❌}-{❌}letter{❌}:{❌}[{❌}"a"{❌}-{❌}"z"{❌};{❌}"A"{❌}-{❌}"Z"{❌}]{❌}.{❌}
#

<ixml>
   <comment>❌</comment>
   <rule name='ixml'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <repeat1>
            <nonterminal name='rule'>
               <comment>❌</comment>
            </nonterminal>+
            <comment>❌</comment>
            <sep>
               <nonterminal name='S'>
                  <comment>❌</comment>
               </nonterminal>
            </sep>
         </repeat1>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='S'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <repeat0>(
            <comment>❌</comment>
            <alts>
               <alt>
                  <nonterminal name='whitespace'>
                     <comment>❌</comment>
                  </nonterminal>
               </alt>;
               <comment>❌</comment>
               <alt>
                  <nonterminal name='comment'>
                     <comment>❌</comment>
                  </nonterminal>
               </alt>
            </alts>)
            <comment>❌</comment>*
            <comment>❌</comment>
         </repeat0>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='whitespace'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <inclusion tmark='-'>
            <comment>❌</comment>[
            <comment>❌</comment>
            <class code='Zs'>
               <comment>❌</comment>
            </class>]
            <comment>❌</comment>
         </inclusion>
      </alt>;
      <comment>❌</comment>
      <alt>
         <nonterminal name='tab'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <alt>
         <nonterminal name='lf'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <alt>
         <nonterminal name='cr'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='tab'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <literal tmark='-' hex='9'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='lf'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <literal tmark='-' hex='a'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='cr'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <literal tmark='-' hex='d'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='comment'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <literal tmark='-' dstring='{'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <repeat0>(
            <comment>❌</comment>
            <alts>
               <alt>
                  <nonterminal name='cchar'>
                     <comment>❌</comment>
                  </nonterminal>
               </alt>;
               <comment>❌</comment>
               <alt>
                  <nonterminal name='comment'>
                     <comment>❌</comment>
                  </nonterminal>
               </alt>
            </alts>)
            <comment>❌</comment>*
            <comment>❌</comment>
         </repeat0>,
         <comment>❌</comment>
         <literal tmark='-' dstring='}'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='cchar'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <exclusion>~
            <comment>❌</comment>[
            <comment>❌</comment>
            <literal dstring='{}'>
               <comment>❌</comment>
            </literal>]
            <comment>❌</comment>
         </exclusion>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='rule'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <option>(
            <comment>❌</comment>
            <alts>
               <alt>
                  <nonterminal name='mark'>
                     <comment>❌</comment>
                  </nonterminal>,
                  <comment>❌</comment>
                  <nonterminal name='S'>
                     <comment>❌</comment>
                  </nonterminal>
               </alt>
            </alts>)
            <comment>❌</comment>?
            <comment>❌</comment>
         </option>,
         <comment>❌</comment>
         <nonterminal name='name'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <inclusion>[
            <comment>❌</comment>
            <literal dstring='=:'>
               <comment>❌</comment>
            </literal>]
            <comment>❌</comment>
         </inclusion>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <nonterminal mark='-' name='alts'>
            <comment>❌</comment>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <literal dstring='.'>
            <comment>❌</comment>
         </literal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='@' name='mark'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <inclusion>[
            <comment>❌</comment>
            <literal dstring='@^-'>
               <comment>❌</comment>
            </literal>]
            <comment>❌</comment>
         </inclusion>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='alts'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <repeat1>
            <nonterminal name='alt'>
               <comment>❌</comment>
            </nonterminal>+
            <comment>❌</comment>
            <sep>(
               <comment>❌</comment>
               <alts>
                  <alt>
                     <inclusion>[
                        <comment>❌</comment>
                        <literal dstring=';|'>
                           <comment>❌</comment>
                        </literal>]
                        <comment>❌</comment>
                     </inclusion>,
                     <comment>❌</comment>
                     <nonterminal name='S'>
                        <comment>❌</comment>
                     </nonterminal>
                  </alt>
               </alts>)
               <comment>❌</comment>
            </sep>
         </repeat1>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='alt'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <repeat0>
            <nonterminal name='term'>
               <comment>❌</comment>
            </nonterminal>*
            <comment>❌</comment>
            <sep>(
               <comment>❌</comment>
               <alts>
                  <alt>
                     <literal dstring=','>
                        <comment>❌</comment>
                     </literal>,
                     <comment>❌</comment>
                     <nonterminal name='S'>
                        <comment>❌</comment>
                     </nonterminal>
                  </alt>
               </alts>)
               <comment>❌</comment>
            </sep>
         </repeat0>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='term'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='factor'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <nonterminal name='option'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <nonterminal name='repeat0'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <nonterminal name='repeat1'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='factor'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='terminal'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <nonterminal name='nonterminal'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <literal dstring='('>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <nonterminal name='alts'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <literal dstring=')'>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='repeat0'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='factor'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <literal dstring='*'>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <option>
            <nonterminal name='sep'>
               <comment>❌</comment>
            </nonterminal>?
            <comment>❌</comment>
         </option>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='repeat1'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='factor'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <literal dstring='+'>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <option>
            <nonterminal name='sep'>
               <comment>❌</comment>
            </nonterminal>?
            <comment>❌</comment>
         </option>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='option'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='factor'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <literal dstring='?'>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='sep'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='factor'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='nonterminal'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <option>(
            <comment>❌</comment>
            <alts>
               <alt>
                  <nonterminal name='mark'>
                     <comment>❌</comment>
                  </nonterminal>,
                  <comment>❌</comment>
                  <nonterminal name='S'>
                     <comment>❌</comment>
                  </nonterminal>
               </alt>
            </alts>)
            <comment>❌</comment>?
            <comment>❌</comment>
         </option>,
         <comment>❌</comment>
         <nonterminal name='name'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='terminal'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='literal'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <nonterminal name='charset'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='literal'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='quoted'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <nonterminal name='encoded'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='quoted'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <option>(
            <comment>❌</comment>
            <alts>
               <alt>
                  <nonterminal name='tmark'>
                     <comment>❌</comment>
                  </nonterminal>,
                  <comment>❌</comment>
                  <nonterminal name='S'>
                     <comment>❌</comment>
                  </nonterminal>
               </alt>
            </alts>)
            <comment>❌</comment>?
            <comment>❌</comment>
         </option>,
         <comment>❌</comment>
         <nonterminal mark='-' name='string'>
            <comment>❌</comment>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='@' name='name'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='namestart'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <repeat0>
            <nonterminal name='namefollower'>
               <comment>❌</comment>
            </nonterminal>*
            <comment>❌</comment>
         </repeat0>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='namestart'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <inclusion>[
            <comment>❌</comment>
            <literal dstring='_'>
               <comment>❌</comment>
            </literal>;
            <comment>❌</comment>
            <class code='Ll'>
               <comment>❌</comment>
            </class>;
            <comment>❌</comment>
            <class code='Lu'>
               <comment>❌</comment>
            </class>;
            <comment>❌</comment>
            <class code='Lm'>
               <comment>❌</comment>
            </class>;
            <comment>❌</comment>
            <class code='Lt'>
               <comment>❌</comment>
            </class>;
            <comment>❌</comment>
            <class code='Lo'>
               <comment>❌</comment>
            </class>]
            <comment>❌</comment>
         </inclusion>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='namefollower'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='namestart'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <alt>
         <inclusion>[
            <comment>❌</comment>
            <literal dstring='-.·‿⁀'>
               <comment>❌</comment>
            </literal>;
            <comment>❌</comment>
            <class code='Nd'>
               <comment>❌</comment>
            </class>;
            <comment>❌</comment>
            <class code='Mn'>
               <comment>❌</comment>
            </class>]
            <comment>❌</comment>
         </inclusion>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='@' name='tmark'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <inclusion>[
            <comment>❌</comment>
            <literal dstring='^-'>
               <comment>❌</comment>
            </literal>]
            <comment>❌</comment>
         </inclusion>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='string'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <literal tmark='-' sstring='"'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='dstring'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <literal tmark='-' sstring='"'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <literal tmark='-' dstring='&apos;'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='sstring'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <literal tmark='-' dstring='&apos;'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='@' name='dstring'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <repeat1>
            <nonterminal name='dchar'>
               <comment>❌</comment>
            </nonterminal>+
            <comment>❌</comment>
         </repeat1>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='@' name='sstring'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <repeat1>
            <nonterminal name='schar'>
               <comment>❌</comment>
            </nonterminal>+
            <comment>❌</comment>
         </repeat1>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='dchar'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <exclusion>~
            <comment>❌</comment>[
            <comment>❌</comment>
            <literal sstring='"'>
               <comment>❌</comment>
            </literal>]
            <comment>❌</comment>
         </exclusion>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <literal sstring='"'>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <literal tmark='-' sstring='"'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>
      <comment>❌</comment>all
      <comment>❌</comment>characters
      <comment>❌</comment>,
      <comment>❌</comment>quotes
      <comment>❌</comment>must
      <comment>❌</comment>be
      <comment>❌</comment>doubled
      <comment>❌</comment>
   </comment>
   <comment>❌</comment>
   <rule name='schar'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <exclusion>~
            <comment>❌</comment>[
            <comment>❌</comment>
            <literal dstring='&apos;'>
               <comment>❌</comment>
            </literal>]
            <comment>❌</comment>
         </exclusion>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <literal dstring='&apos;'>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <literal tmark='-' dstring='&apos;'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>
      <comment>❌</comment>all
      <comment>❌</comment>characters
      <comment>❌</comment>,
      <comment>❌</comment>quotes
      <comment>❌</comment>must
      <comment>❌</comment>be
      <comment>❌</comment>doubled
      <comment>❌</comment>
   </comment>
   <comment>❌</comment>
   <rule mark='-' name='encoded'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <option>(
            <comment>❌</comment>
            <alts>
               <alt>
                  <nonterminal name='tmark'>
                     <comment>❌</comment>
                  </nonterminal>,
                  <comment>❌</comment>
                  <nonterminal name='S'>
                     <comment>❌</comment>
                  </nonterminal>
               </alt>
            </alts>)
            <comment>❌</comment>?
            <comment>❌</comment>
         </option>,
         <comment>❌</comment>
         <literal tmark='-' dstring='#'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal mark='@' name='hex'>
            <comment>❌</comment>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='hex'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <repeat1>
            <inclusion>[
               <comment>❌</comment>
               <range from='0❌' to='9❌'>-
                  <comment>❌</comment>
               </range>;
               <comment>❌</comment>
               <range from='a❌' to='f❌'>-
                  <comment>❌</comment>
               </range>;
               <comment>❌</comment>
               <range from='A❌' to='F❌'>-
                  <comment>❌</comment>
               </range>]
               <comment>❌</comment>
            </inclusion>+
            <comment>❌</comment>
         </repeat1>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='charset'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='inclusion'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <nonterminal name='exclusion'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='inclusion'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <option>(
            <comment>❌</comment>
            <alts>
               <alt>
                  <nonterminal name='tmark'>
                     <comment>❌</comment>
                  </nonterminal>,
                  <comment>❌</comment>
                  <nonterminal name='S'>
                     <comment>❌</comment>
                  </nonterminal>
               </alt>
            </alts>)
            <comment>❌</comment>?
            <comment>❌</comment>
         </option>,
         <comment>❌</comment>
         <nonterminal name='set'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='exclusion'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <option>(
            <comment>❌</comment>
            <alts>
               <alt>
                  <nonterminal name='tmark'>
                     <comment>❌</comment>
                  </nonterminal>,
                  <comment>❌</comment>
                  <nonterminal name='S'>
                     <comment>❌</comment>
                  </nonterminal>
               </alt>
            </alts>)
            <comment>❌</comment>?
            <comment>❌</comment>
         </option>,
         <comment>❌</comment>
         <literal dstring='~'>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <nonterminal name='set'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='set'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <literal dstring='['>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <repeat0>
            <nonterminal name='member'>
               <comment>❌</comment>
            </nonterminal>*
            <comment>❌</comment>
            <sep>(
               <comment>❌</comment>
               <alts>
                  <alt>
                     <inclusion>[
                        <comment>❌</comment>
                        <literal dstring=';|'>
                           <comment>❌</comment>
                        </literal>]
                        <comment>❌</comment>
                     </inclusion>,
                     <comment>❌</comment>
                     <nonterminal name='S'>
                        <comment>❌</comment>
                     </nonterminal>
                  </alt>
               </alts>)
               <comment>❌</comment>
            </sep>
         </repeat0>,
         <comment>❌</comment>
         <literal dstring=']'>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='member'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='literal'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <nonterminal name='range'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <nonterminal name='class'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='range'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='from'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <literal dstring='-'>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <nonterminal name='to'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='@' name='from'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='character'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='@' name='to'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='character'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='character'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <literal tmark='-' sstring='"'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='dchar'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <literal tmark='-' sstring='"'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <literal tmark='-' dstring='&apos;'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='schar'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <literal tmark='-' dstring='&apos;'>
            <comment>❌</comment>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>
      </alt>;
      <comment>❌</comment>
      <comment>❌</comment>
      <alt>
         <literal dstring='#'>
            <comment>❌</comment>
         </literal>,
         <comment>❌</comment>
         <nonterminal name='hex'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='class'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal mark='@' name='code'>
            <comment>❌</comment>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <nonterminal name='S'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule name='code'>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <nonterminal name='letter'>
            <comment>❌</comment>
         </nonterminal>,
         <comment>❌</comment>
         <nonterminal name='letter'>
            <comment>❌</comment>
         </nonterminal>
      </alt>.</rule>
   <comment>❌</comment>
   <comment>❌</comment>
   <rule mark='-' name='letter'>
      <comment>❌</comment>
      <comment>❌</comment>:
      <comment>❌</comment>
      <alt>
         <inclusion>[
            <comment>❌</comment>
            <range from='a❌' to='z❌'>-
               <comment>❌</comment>
            </range>;
            <comment>❌</comment>
            <range from='A❌' to='Z❌'>-
               <comment>❌</comment>
            </range>]
            <comment>❌</comment>
         </inclusion>
      </alt>.</rule>
   <comment>❌</comment>
</ixml>
