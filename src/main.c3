module lsc3;
import libc;
import std::io;

//

struct Options {
  bool list_all;
  bool show_date;
  bool show_author;
}

// filesystem bindings

def Fd = CInt;

struct Dir {
  Fd fd;
  void* buffer;
}

struct Dirent {
  ulong d_ino;
  ulong d_off;
  ushort d_reclen;
  char d_type;
  char[256] d_name;
}

extern fn Dir *opendir(ZString name);
extern fn Dirent *readdir(Dir *dir);
extern fn void closedir(Dir *dir);

const int DT_DIR @extern("DT_DIR") = 4;
const int DT_REG @extern("DT_REG") = 8;
const int DT_LNK @extern("DT_LNK") = 10;

const String CLEAR =  "\x1B[0m";
const String GREEN = "\x1B[32m";
const String BLUE =  "\x1B[34m";


fn String get_color(int kind) {
  if (kind == DT_DIR) return BLUE;
  return CLEAR;
}

fn void list_dir(ZString path) {
  Dir *dir;
  Dirent *entry;
  String str_path = (path).str_view();
  if ((dir = opendir(path)) == null) return;
  while ((entry = readdir(dir)) != null) {
    if (entry.d_type != DT_DIR && entry.d_type != DT_REG) continue;
    
    DString result;
    ZString name = (ZString) (entry.d_name[0..255]);
    
    result.append(get_color(entry.d_type));
    if(libc::strncmp(name, "..", 2) != 0 && libc::strncmp(name, ".", 2) != 0) {
      result.append(str_path);
      result.append("/");
    }
    result.append((String)entry.d_name[0..name.len()]);
    result.append(CLEAR);
    result.append("\n");
    
    io::print(result);
  }
  closedir(dir);
}

fn Options parse_args(String[] args) {
  return Options{};
}

fn void main(String[] args)
{
  Options opts = parse_args(args);
  list_dir(".", opts);
}
