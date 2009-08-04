Name:           squeezebox-release
Version:        1
Release:        1
Summary:        SqueezeBox Yum Repo Configuration

Group:          System Environment/Base
License:        GPL
URL:           	http://www.slimdevices.com/
Source:		squeezebox.repo
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildArch:      noarch

%description
SqueezeBox Yum Repo Configuration


%prep
%setup -c -T


%build


%install
rm -rf $RPM_BUILD_ROOT
install -dm 755 $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d
install -pm 644 %{SOURCE0} \
    $RPM_BUILD_ROOT%{_sysconfdir}/yum.repos.d


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%config %{_sysconfdir}/yum.repos.d/*

