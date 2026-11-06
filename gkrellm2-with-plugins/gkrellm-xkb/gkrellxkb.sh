#! @shell@

test -d ~/.gkrellm2/plugins || {
  mkdir ~/.gkrellm2/plugins
}
  cp -r "@out@/gkrellm2/plugins/"/* ~/.gkrellm2/plugins
#@out@/bin/gkrellcount
