
###
# Standalone class to manage code distribution
# This class is intended to be mixed into another class
# (Thus the lack of ancestors)
###
oo::class create ::practcl::distribution {

  method DistroMixIn {} {
    my define set scm none
  }

  method Sandbox {} {
    if {[my define exists sandbox]} {
      return [my define get sandbox]
    }
    if {[my organ project] ni {::noop {}}} {
      set sandbox [my <project> define get sandbox]
      if {$sandbox ne {}} {
        my define set sandbox $sandbox
        return $sandbox
      }
    }
    set sandbox [file normalize [file join $::CWD .. $pkg]]
    my define set sandbox $sandbox
    return $sandbox
  }

  method SrcDir {} {
    set pkg [my define get name]
    if {[my define exists srcdir]} {
      return [my define get srcdir]
    }
    set sandbox [my Sandbox]
    set srcdir [file join [my Sandbox] $pkg]
    my define set srcdir $srcdir
    return $srcdir
  }

  method ScmSelect {} {
    if {[my define exists scm]} {
      return [my define get scm]
    }
    set srcdir [my SrcDir]
    set classprefix ::practcl::distribution.
    if {[file exists $srcdir]} {
      foreach class [::info commands ${classprefix}*] {
        if {[$class claim_path $srcdir]} {
          oo::objdefine [self] mixin $class
          my define set scm [string range $class [string length ::practcl::distribution.] end]
        }
      }
    }
    foreach class [::info commands ${classprefix}*] {
      if {[$class claim_object [self]]} {
        oo::objdefine [self] mixin $class
        my define set scm [string range $class [string length ::practcl::distribution.] end]
      }
    }
    if {[my define get scm] eq {} && [my define exists file_url]} {
      set class
    }

    if {[my define get scm] eq {}} {
      error "No SCM selected"
    }
    return [my define get scm]
  }

  method ScmTag    {} {}
  method ScmClone  {} {}
  method ScmUnpack {} {}
  method ScmUpdate {} {}

  method unpack {} {
    my ScmSelect
    set srcdir [my SrcDir]
    if {[file exists $srcdir]} {
      return
    }
    set pkg [my define get name]
    if {[my define exists download]} {
      # Utilize a staged download
      set download [my define get download]
      if {[file exists [file join $download $pkg.zip]]} {
        ::practcl::tcllib_require zipfile::decode
        ::zipfile::decode::unzipfile [file join $download $pkg.zip] $srcdir
        return
      }
    }
    my ScmUnpack
  }

  method update {} {
    my ScmSelect
    my ScmUpdate
  }
}

oo::objdefine ::practcl::distribution {
  method claim_path path {
    return false
  }
  method claim_object object {
    return false
  }
}
