autocmd VimEnter,BufRead,BufNewFile **/exercism/*/*/* call s:Setup()
function s:Setup()
  if s:Track() == "csharp"
    "" CSharp doesn't work yet, sorry
    return
  endif
  nnoremap <leader>t :call <sid>RunTests()<cr>
  nnoremap <leader>r :e README.md<cr>
  nnoremap <leader><leader> :call <sid>SwapFiles()<cr>

  "" Ocaml nicks the <leader>t binding for itself,
  "" so use <leader>m (for make) instead.
  if s:Track() == "ocaml"
    nnoremap <leader>m :call <sid>RunTests()<cr>
  endif
endfunction

function s:StripNewline(str)
  return a:str[0 : strlen(a:str) - 2]
endfunction

function s:StripDotSlash(str)
  return a:str[2 : strlen(a:str) - 1]
endfunction

function s:Track()
  let track = system("pwd | awk -F'/' '{print $(NF-1)}'")
  return s:StripNewline(track)
endfunction

function s:TestCommand()
  let track = s:Track()
  if     track == "clojure"      | return "lein exec "             . s:TestFile()
  elseif track == "coffeescript" | return "jasmine-node --coffee " . s:TestFile()
  elseif track == "elixir"       | return "elixir "                . s:TestFile()
  elseif track == "go"           | return "go test"
  elseif track == "haskell"      | return "runhaskell -Wall "      . s:TestFile()
  elseif track == "javascript"   | return "jasmine-node "          . s:TestFile()
  elseif track == "objective-c"  | return "objc "                  . s:ObjectiveCExerciseName()
  elseif track == "ocaml"        | return "make"
  elseif track == "perl5"        | return "prove "                 . s:TestFile()
  elseif track == "python"       | return "python "                . s:TestFile()
  elseif track == "ruby"         | return "ruby "                  . s:TestFile()
  elseif track == "scala"        | return "sbt test"
  endif
endfunction

function s:ObjectiveCExerciseName()
  let name = system("find . -name \"*.h\" | xargs basename | awk -F'.' '{print $1}'")
  return s:StripNewline(name)
endfunction

function s:RunTests()
  execute("!" . s:TestCommand())
endfunction

function s:TestFile()
  let track = s:Track()
  if     track == "clojure"      | let pattern = "*_test.clj"
  elseif track == "coffeescript" | let pattern = "*test.spec.coffee"
  elseif track == "elixir"       | let pattern = "*_test.exs"
  elseif track == "go"           | let pattern = "*_test.go"
  elseif track == "haskell"      | let pattern = "*_test.hs"
  elseif track == "javascript"   | let pattern = "*test.spec.js"
  elseif track == "objective-c"  | let pattern = "*Test.m"
  elseif track == "ocaml"        | let pattern = "*test.ml"
  elseif track == "perl5"        | let pattern = "*.t"
  elseif track == "python"       | let pattern = "*_test.py"
  elseif track == "ruby"         | let pattern = "*_test.rb"
  elseif track == "scala"
    let scala_test_file = system("find . -name *.scala | grep test | head -n 1")
    return s:StripDotSlash(s:StripNewline(scala_test_file))
  endif

  let test_file = system("find . -name \"" . pattern . "\" | xargs basename | head -n 1")
  return s:StripNewline(test_file)
endfunction

function s:SourceFile()
  let track = s:Track()
  if     track == "clojure"      | let pattern = "*.clj"
  elseif track == "coffeescript" | let pattern = "*.coffee"
  elseif track == "elixir"       | let pattern = "*.exs"
  elseif track == "go"           | let pattern = "*.go"
  elseif track == "haskell"      | let pattern = "*.hs"
  elseif track == "javascript"   | let pattern = "*.js"
  elseif track == "objective-c"  | let pattern = "*.m"
  elseif track == "ocaml"        | let pattern = "*.ml"
  elseif track == "perl5"        | let pattern = "*.pm"
  elseif track == "python"       | let pattern = "*.py"
  elseif track == "ruby"         | let pattern = "*.rb"
  elseif track == "scala"
    let scala_source_file = system("find . -name *.scala | grep -v test | head -n 1")
    return s:StripDotSlash(s:StripNewline(scala_source_file))
  endif
  let source_file = system("find . -name \"" . pattern . "\" | grep -v " . s:TestFile() . " | xargs basename | head -n 1")
  return s:StripNewline(source_file)
endfunction

function s:SwapFiles()
  if expand("%") == s:SourceFile() | exec ':e ' . s:TestFile()
  else                             | exec ':e ' . s:SourceFile()
  endif
endfunction
