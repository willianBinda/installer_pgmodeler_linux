
# Install build dependencies
sudo apt install build-essential libxml2-dev perl libx11-xcb-dev \
  ^libxcb.*-dev libfontconfig1-dev libfreetype6-dev libx11-dev \
  libx11-xcb-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev \
  libxcb1-dev libxcb-glx0-dev libxcb-keysyms1-dev libxcb-image0-dev \
  libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync0-dev libxcb-xfixes0-dev \
  libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0-dev \
  libxkbcommon-dev libxkbcommon-x11-dev libxcb-xinerama0-dev \
  libxcb-sync-dev libcups2-dev -y

# Set up the local environment
export QT_DIR=~/code/qt
export QT_VERSION=6.2.4
export QT_ARCH=gcc_64
export QT_ROOT=$QT_DIR/$QT_VERSION/$QT_ARCH
export QT_LIB=$QT_ROOT/lib
export PGMODELER_SOURCE=~/code/pgmodeler/pgmodeler
export PGMODELER_VERSION=v1.1.2
export INSTALLATION_ROOT=~/code/pgmodeler/bin/$PGMODELER_VERSION
mkdir -p $QT_ROOT \
 $INSTALLATION_ROOT/lib/qtplugins/imageformats \
 $INSTALLATION_ROOT/lib/qtplugins/printsupport \
 $INSTALLATION_ROOT/lib/qtplugins/platforms \
 $INSTALLATION_ROOT/lib/qtplugins/tls

# Install Qt6
# Install Qt installation tools
pip install aqtinstall
#Install Qt6
cd $QT_DIR && \
python3 -m aqt install-qt linux desktop $QT_VERSION $QT_ARCH

# Compile pgModeler
# Get the pgModeler repo
cd ~/code/pgmodeler
git clone https://github.com/pgmodeler/pgmodeler.git
cd $PGMODELER_SOURCE
git pull
git checkout $PGMODELER_VERSION

# Configure the pgModeler build
export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig/
cd $PGMODELER_SOURCE
$QT_ROOT/bin/qmake -r CONFIG+=release \
  PREFIX=$INSTALLATION_ROOT \
  BINDIR=$INSTALLATION_ROOT \
  PRIVATEBINDIR=$INSTALLATION_ROOT \
  PRIVATELIBDIR=$INSTALLATION_ROOT/lib \
  pgmodeler.pro

# Build pgModeler
cd $PGMODELER_SOURCE
make -j$(nproc)
make install

# Resolve pgModeler dependencies
cd $QT_LIB
cp libQt6DBus.so.6 libQt6PrintSupport.so.6 libQt6Widgets.so.6 \
  libQt6Network.so.6 libQt6Gui.so.6 libQt6Core.so.6 libQt6XcbQpa.so.6 \
  libQt6Svg.so.6 libQt6OpenGL.so.6 libicui18n.so.* libicuuc.so.* \
  libicudata.so.* \
  $INSTALLATION_ROOT/lib
cd $QT_ROOT/plugins
cp -r imageformats/libqgif.so imageformats/libqico.so \
  imageformats/libqjpeg.so imageformats/libqsvg.so \
  $INSTALLATION_ROOT/lib/qtplugins/imageformats
cp -r printsupport/libcupsprintersupport.so \
  $INSTALLATION_ROOT/lib/qtplugins/printsupport
cp -r platforms/libqxcb.so platforms/libqoffscreen.so \
  $INSTALLATION_ROOT/lib/qtplugins/platforms
cp -r tls/* \
  $INSTALLATION_ROOT/lib/qtplugins/tls
echo -e \
  "[Paths]\nPrefix=.\nPlugins=lib/qtplugins\nLibraries=lib" \
  > $INSTALLATION_ROOT/qt.conf

# Run pgModeler
# If needed - (re)create pgModeler runtime config files
rm -rf ~/.config/pgmodeler-1.1
cd $INSTALLATION_ROOT && ./pgmodeler-cli -cc -mo

# Run pgModeler from the terminal
cd ~/code/pgmodeler/bin/v1.1.2 && \
 export LD_LIBRARY_PATH=$(pwd)/lib && \
 ./pgmodeler &

# Create Desktop shortcut
export PGMODELER_DESKTOP_SHORTCUT=~/Desktop/pgModeler-v104.desktop
echo '[Desktop Entry]' > $PGMODELER_DESKTOP_SHORTCUT
echo 'Comment=Starts pgModeler v1.1.2' >> $PGMODELER_DESKTOP_SHORTCUT
echo 'Exec=sh -c "cd ~/code/pgmodeler/bin/v1.1.2 && export LD_LIBRARY_PATH=$(pwd)/lib && ./pgmodeler"' >> $PGMODELER_DESKTOP_SHORTCUT
echo 'GenericName=pgModeler v1.1.2' >> $PGMODELER_DESKTOP_SHORTCUT
echo 'Icon=~/code/pgmodeler/bin/v1.1.2/share/pgmodeler/conf/pgmodeler_logo.png' >> $PGMODELER_DESKTOP_SHORTCUT
echo 'Name=pgModeler v1.1.2' >> $PGMODELER_DESKTOP_SHORTCUT
echo 'Type=Application' >> $PGMODELER_DESKTOP_SHORTCUT
echo 'Terminal=false' >> $PGMODELER_DESKTOP_SHORTCUT
gio set $PGMODELER_DESKTOP_SHORTCUT metadata::trusted true
chmod +x $PGMODELER_DESKTOP_SHORTCUT

# Run pgModeler from the Desktop shortcut like so:
# Right-click on the pgModeler-v104 desktop icon and select 'Allow Launching'
# Double click on the pgModeler-v104 shortcut on the desktop
