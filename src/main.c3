module lsc3;
import libc;
import std::io;
import std::collections;

//

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
const String TEST =  "\x1B[34m";

const int LIST_ALL = 0;
const int LIST_ALMOST_ALL = 1;
const int SHOW_AUTHOR = 2;
const int LIST_NORMAL = 3;

//

fn String get_color(int kind) {
  if (kind == DT_DIR) return BLUE;
  return CLEAR;
}

fn List(<DString>) list_dir(ZString path, int style) {
  Dir *dir;
  Dirent *entry;
  String str_path = (path).str_view();
  if ((dir = opendir(path)) == null) return List(<DString>){};
  List(<DString>) output;
  while ((entry = readdir(dir)) != null) {
    if (entry.d_type != DT_DIR && entry.d_type != DT_REG) continue;
    
    DString result;
    ZString name = (ZString) (entry.d_name[0..255]);
    if(style != LIST_ALL && (libc::strncmp(name, "..", 2) == 0 || libc::strncmp(name, ".", 1) == 0)) continue;
    result.append(get_color(entry.d_type));
    if(libc::strncmp(name, "..", 2) != 0 && libc::strncmp(name, ".", 2) != 0) {
      result.append(str_path);
      result.append("/");
    }
    result.append((String)entry.d_name[0..name.len()]);
    result.append(CLEAR);
    result.append("\n");
    if (entry.d_type == DT_DIR) {
      output.push_front(result);
    } else {
      output.push(result);
    }
  }
  closedir(dir);
  return output;
}

fn int parse_args(String[] args) {
  foreach (&arg : args) {
    if (libc::strncmp(*arg, "-A", arg.len) == 0) {
      return 1;
    }
    if (libc::strncmp(*arg, "-a", arg.len) == 0) {
      return 0;
    }
  }
  return 3;
}

fn void main(String[] args)
{
  int style = parse_args(args);
  List(<DString>) result = list_dir(".", style);
  foreach(&line : result) {
    io::print(*line);
  }
}
