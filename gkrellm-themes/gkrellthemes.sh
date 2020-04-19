#! @shell@

test -d ~/.gkrellm2/themes || {
  mkdir ~/.gkrellm2/themes
}
   cp -r "@out@/usr/share/gkrellm2/themes/"/* ~/.gkrellm2/themes

       # Several directories in the tarballs are 777 and files 755, some SGID.
      # The tar extract options should have fixed this, let's be 100% sure.
    cd ~/.gkrellm2/themes
    find . -type d -print0 | xargs -0 chmod 0755
    find . -type f -print0 | xargs -0 chmod 0644
#@out@/bin/gkrellcount
