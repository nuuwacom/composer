ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.17.0
docker tag hyperledger/composer-playground:0.17.0 hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv11/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� K!XZ �<KlIv�lv��A�'3�X��R���n�Dz4��G-�")J��x5��"�R�����׋�6�`� �� 9g����!�CA�S�"�$�5����&EY�-���lU�z�ի��O�b�؊�F�4l15iرWW�Þv�|JJ:�$����Ғ����� ��B<)��|ZH�.��9�nqmG���Xҡj�wZ�7�b�V=���9��֡*c;�qy:a�����;��ckO�z8��F�'u��;4��a���ب=�R�4,�f(������x��w�ӱ�7�ڪ��j�[����Mr���roZ���ҖZ�*G|!��;w��3�ԉ�ŷ�� �O���%�:wNf����g�?��J�v�h��O�<�	��?�'R���3Ia��/�,~k�z�%�]�6\K�(�t�
�QT��Zx~�����6��ң��gat3��]Cf_��؞fH
�@_8n�Xn��nQ7{H�aB4E"����t���g����i9~S��w�d)F_5�H��W��ؿ ����$��D�D!��s����nEmW�H
�ӕt��5J��,�31Tbd����qRhs~'�1�7��W�W�n(T��i�ȓ���F����x0��VP8��!(uH���5Px���	�F��)����tW�H��(P>)f��qa���.�H�A9"�VQ�(�&t�)��4�R�Y��$�1��%�@��jc�=�'�v:���V	���Uâ�f6;2|fn膃��d��8�G,W�:R�rr��+9�Ɣ�6�	��f�OB[���x+
���=t	@WwU�v"�+<�.��p���J��a�������r&��OQ�c���������aO��=��	��M�C4�!��i�<�b�`����%
�k�&p����Z���NQ��h��@Y8<P�ے�)�����m-3��Ț�m	pZ���T��I����)�����ˋ��?��s�q����D����B<���8Y��3���_DayRb�0{XwXvf˖j:��ߌL�dc������5Kj�͵,� �$?�5�^v#��^���*4ʵ�������-��K������� ��%�+G� �]�rao���*oVo���f/� @��\���m��m�Gt��!�ٸF�V�^3�l|2N�HVח&��Y�P9��VSl4���Jis�y2�`�x�S膍a���!L�^�Sl$-����<�G��o-]'��G��#�4��ʏВ�����_����DVs�
���t���V}zM�C�Rē�D&�tZ� �X�M"��1��c�i� ��A��Y��d3��)�����ۆ~.4��_���?��� �?��0���?	?s��)�\���p��+C�6i�		H<��<�V03*�ik)�34b��$aV 9�q\�q��9�v��Zd�#lZ����Ŵ��Ю���O��	;@�pЁ�mV�Z��:�i�b1h麭�l�b3)���(�ݟQB��t�,0���OSeN� �`6]�q�t��}�Rlh{�X
q���@�J�>��ͥ{�������m���D$Kئw5E"䧭jE���H��xP �"6��`]Vq '�$�~��f���R�����&�э�`~���T˨�B�{�vx�oVy���]�'�����2_���e���a����K�:�I���"�����2��eC�]����� x5Gp6���Y�e���?1��S���v���ЭYYR��8���tf�������b���?�UA�o���R�T'���`��2�)�m=t��h!�6��f�"4w2�Uf��Ԇ���x��ߙx*=��}����G\����i�ߛ>�g�dR��?��?�������
o�2�0�<��d�Ϥ�9� d����)S�K���Q[�la�2��ȴT��.��z���Q��F0�m�R߸��r��6<z�-9���(���E��=�ɮJ�F�>~ہ>�����#i7֥dLe��I�g(�8��@���&@�Y�3��I���D���6g�K�GhiE:���y��؅N���\XX�D�X3o�ǅ�ҽZ����B��hM�f&}���T��;�.�v�*���D��zosa��m�[�8�3��>��{�# o[YAa�.x�!:[��|��ry��/�'��(��|��d0���5���ٝ��\7���j�^i�?��Ŕ�w[A��V����=�x�$���hE��͔1R`����`�- �K�7pF�� ��T�63W�A:��y�g˷�ېw�.~�U�O4�"����O�7���I�f�Ty���&�;����0����f��XOBGdP��?S����X�k�x�ed�� 5��̲�/��{K1���)�d�q���IG�`fbؑ�N����q�cc:��wU?�%`щQW�l��j%P��V��Y]-������1&z����i�"�l��I0���Hkz�Qz(���]�a�]e��&��uD��e��3�4֛�oi9s��
��O����?��� ��y�w�U�E�O$��X�}�$a�\�!G�P�$��~)��e/�>�$��.�Sx�s4LG�(��PU�?��,�T/�/�ыb/E�p�Қ��M+⼼�rf����/N��?c�ϓ��������QJg�B������t"���%�!�?ɔ0����K,�Zj��r�Yf�?��FL�B�r�$�׊"�ح�HY����UFh|��H$�-�s������"���ۘ�L1]K����F=i�Z��ku��Ơ�6�L�W(*�F�dA
␷�G�5O�;���mh��y�����oo�8��ul�����s�G�|�C{-E�9${`��H�z$�͵�&�!�Qo �[ kX������xGy
E�j��v��Bs3��͠냉���2�6C4�֗0���z�/�&��u�٥/���(���J��}�7%��4����}U�(6�{�N2X�R���{}�>%f*gp*t����I:�lՐk�'MA�Q������)H��Ƞ\+>�Z��2y�\g��s	9�m!�Ee ��V��ٜ_�a��ӟ ����x2'�d�l�cz|F����K^A���E�j:y��T��������u��:�J�8��-} DU�pO�"�ih���=:]oh��l�Ȅ���*r`h:F����2Ħ���9������\Ku�tւ{�� [b5X�ʪ)i9�0 c�Tɗ�xR=���m:�y����8[�d�;)�Y��g=�uv�S ]���1�a�M���g����S?pA�c"�ɖa���tPT�n[�����}T�0������(��)\������Ĉ*�����8����A���Nؘ�
85�m9���^c�)��ͪ�N�5TR41br	���Y>��X�%�Ͱ(�I�QOˈA�轟q��z�˔|G�~/Pxը94����Y�Jf�X�4��;n���PR5z�H�<�x)%ys��]����>���#�(F[T�6XB����y��o�=l��W�.���t��?xia��w{�~��H_��b��$�-��<����&�=`�~�b��AU����)���"P����0c�'ԞۛE К���P�΂�S�&<l2>�&��Kt���2�ը�8��";�F��F3��$�[�����1�cƢc� ���2����h�e�)�L����C�y�{N��GT��G�d�`�6M ��	�Y��<�������Id��I.@9o$< ÚjS��0�������<�� bW�m�ʵ=��g27њrӼ��җ\s�xV{�@��F#�����i*ނ�QIL$����	�m��G9���[�oLf�����@ �]L(���b�Ap����Z������~Q�?/��w������Oe����T:1?������;����;W߽����;��S�>�'Zq9���m���dVj��Iy9�M�[Y!)d$��q2�̶���,%��l�oe�SBk9�
��;�O�����or��0ą�p�D�2�KW�8n���0��\����տ����I$_\�ry�'�ޥ�;��Я\�V���]2{��܇�(�7B�@~E���� �W1����=�oz�Yy��|:�/�<���'�i�O'���S��U�X�:�������u�~������y������~�_��������ܗ<�{<7�]�����+~F}�{�؝^�Q��?K��	Kq)�P2���D2�R|�S�x|G*)g�N-+� ���rVP� �"t5���w~�u��O��O�_.��˿�7�J���1C�~�n<��r�6�C�a���2��}��<G��\����oU�j�?����y����m��w#��Kk�**���j� 6K����˅�~� �^G��b�\/�mmv���o9���:N����|Q��w:O����z�(��*u���ŝz}�Կ��}TjV���o�
��F]X����^��m��W�uږT��ª[.=r��S�҃�~�����Y�n��J��+[)��:��@�׫��%��7(�8�4w�����j?>��BewPٯ�*�%����_�U�+�x7ߩ���ݦ��4+�J�ĆV.����������zZ�������m���0�d�����zUS����A�O6J�<�_���$w����ڶ�+d�J��_�P�"WT�w�R�W�������|�/��ݲ�\�r��K�A]�ӻ�����}�|�qw��)��tc�bv�a��7����T������v��ͻ����[-�{��Z=����Zc;���TmWV��"a�����X^����*�2��.ȧ"�q�U��/�)p�o��~);M"��z�T��;k��=�إκ��ܦ�Dz���M��F2}X/?0��v��v�|��:�xK����l��Nah�Ǵ�}'�+�:�d����-��vں�1�[���G��N���@��Si���ֶ���e��l������(��Y������i�������S�i�X�\YSC����N��P��׆ƃ�j�������Q�W��t+���ʠt$6�Zv���j����@�]�~i��/n�6�Y܁65��ɽU��hWX�5��h�{Wף8��G�Ѩ㝝1���N����m�o㋕�_l06�Y��6�l0p5��]�(���u.�/�����WSTWUWw۞���E����>�9�}� һ�^X��á�eþN�l�Vyƺ>G1TB��'�ա�*��#	U	nj&�FW���1��v��%��g��),|����<|e#�$���=ۇV��R��f|A丛ǱPe`�a�u��e5DouC���J���9""�Bfː��>6;Ԥ��zV��U���B���"�˪NI�2h��>.�D?����+.BI���/~�%m[�yF�� -�e����F�«$��X�j��NW}kM�KC�V}צ��Tw�j4V0W!� ��*nYk���n��t��"�9I�𰦑'�K��x��ӄI���~��%��gf;��nP�%_'j�|�ʻ��2� �
M�u��Q�MvNS���n1|�c�_C_�U-|��O���<�Qt>	;�S�6]i��h���ڇ'-n��;h&a���Ú��CI�y��%�j�١Jb��BO9�^ Jb����v�y�:Ɵ���7��n���ƶ,Z/���omg��l*Ҝ6��x`�U�2,!80%��-�ߊ'��]!�|�-�����t�?�~����C��mA��4��ՆŌ�1�P�������~�Lu��Z�t�)N�D��6Wf=ӧ��Er!Ɯ�t���'ju���بu��o7VN�oyc�㦛29�e'�V:��-���~WxU�����W���E��n������=���o|�'��'�77�2��9?8�]��_���{�]����LB��/����t߅«�{�����N��e��.y�W�
��]�A�3̅����������m�_�-�˷�瓃��(���*X�1_�ʛ�l�5w�@����s.b�e|�_���9�n�w��5��BL$]�����f�<��=G5�3tM]Z,�7�Gw����#7�=W(P"QL�1X߹	{8��U�a4,�����J�Z�)�Eӭ�4�&�����)�6��d���`
7�Am�7�]'\�q���LX��}wZ��@Zȝ9R����4�Y�|�²�;2��М1����1�3�s=�LB�Ւ�]}��,�Z���,S���E�S�����mw|��χ&#��{��$P�j��Y�	�����ͮh#ư=�v�p�>�6
	����q;v����1Y���{Hi���!>q��ͬnJ#/9�2�K��D�����N�%B�>	e�'�$�=Քu�.���_[������񿭰�1���
�ʞ�2?U����z�wyC���SG�N��;u2?����cqg$ԏ�zn?vw�J㏘���;���6'kM|Z��-�^���Af�m|kҬ7ўk����Lw�z�86��p�}e��۪�Q?nM�4r0WKMj2�r��ƥ�ʐzo�����]Fa�k�,\eNa��v�YF,��Ҝ���V!���%�R�n���.R�pY;x:��!�m/��ω�r���liҐQ�u�閛���r���B�uj#C,�I��Z���m��C��y/�U�s�@(�sf�8tz��e�Q�ӈyY�k|'M�_��	�H��6�(�f�-f݀Z+��CS.TIl���y,27�d[9��	��!E���	��!�c0�nu����:رc0i%r�P�s��x@����;N�[Cr�7�I�&�T�W��2���7}M�|T��bMZ�%���JN��yg(b�}y�	��~�J"�s
t�(��]�K��j��>�\��b͗7��FG.�u�4�p�j�a�S@a�a=��,��2���5B:&�7�n��6���'(�"s�xp�l�.Yl�o{�ښڱ�H��}��㓝��;&�7�ICx�3�t)v�K�����|}�K�.|u.�N�'���k�[���N���oo�h��Up5a^O|�7�/��\w��dM���"��)?@qZrR�M���o~��G�?�����C_��y)|]������G�Wl2�ѱ&��z�}f��8�����s�;蛪&[V1~�C�i"���<����]�oE��z�Z_%�'ݫ�;�W��%蛛�9-F*���o߶�^$�O����?���3��~���)�������F@�Wx���w-���x����?�������?{N�c(
�?�)�)��>���`��"����������F��~�a���������_���C�=�����_ת��6ނ4���O%�?�����S�]�'a�H���k��х ��?���������SAf��Ա��� ��Ϝ�Q��G ���L�߱w�A�x& ��Ϝ�1��d�\�c�/6�Cr����I���������N�����K m�m���wI�Ⱥ�~X�B�!������K��0�g` S ����_.��g��M9����� @:ȅ�����H��� �@�/:=��1r�����@���L�_4	��l���������(��4���zV��\����?$��* ն@�-Pm�9ն������g�L����?K ����_.���̐� �A.�?���`��������\�?��/#d����.��+��� ����y��X�����|�C���v��C�(El�F]�񬁇�	ץ�.���y6m�!p��A�$���c}w?u��1������tp���-�s�E�ׄ����U���6fE8���M�Ir?uɽ����3�����E45��-�ڢ�G��p��LW��k�(��{�"Zd��rX��ֶ�#�1�r�@��M�lY2�O[1��_"��b�ug���˜��j���Bn���Me���y����gv�,�G0��!��������GvȔ��_���f�1�X�������������j�f���PLՊ1��+3V}�kp�:���~O?����7j�Omg5o���t�t�)���Ё7��f��+��R��SZּ�@��
1�E�x�����cq��\h�-���"����oF�4�;�g�)~�?�b���� ����/������j�h���G������K������[��P�hUY���jy�N 
�N������>���}�<[a�"��������A�m,1�2o��DC�G�����M����[��,�5�]/6�K*���/��A�ͅ�Y���T&�`�Y����am�jBmd��Ra�kuv��?i�
4�������u3�+�*���Wi
q�e�v5iw��҂�u�D�
��Xd�	�'j�s��i>��*L 0�߫�r5CMt*�ƣQ�hЫ���N�׷�`�+GI����9���Rn�F����$�#�V�������k�s�A�!�=�?��K=��}^s�4����?���X��r���=�꿤�T�y�- ��Ϛ�Q���_a��i U�^s����]��� ��
�����_3���E�W��_JHE��}^r��_������E�W��?%���`��|!������ ���������迏���>/���/[������i�?��%_ȅ��g���T �����_^.�����>z��98�|"�����@��T���.��B���T���<8��1!s ���5���=�$��4�-���Y�?������e���d�d	����3��b�_��/%��AZHH��ߵ��J���� �?�����{���
��a��ܐ� ��������e�<��=g�a���\��{�?P��c*x���|��q����4��0b�`&�;��J��I���������<��q���3��i*�@7��r@ʛpY�7�ޜ�,tX+K��Hj.��֢�+��S��Ȧ0�K�m�e��ٽ�5T�ΰ�:�m#�ƒӝ-����(Iy�(Iy(�3q����ڤ8���!���`��L�K���a%�73uӶ�I,�SU��r5r��`6��9�a��M�E��"���ً���\�?��@�G*�^���Y�����r������`����+��!SG.��=�1��S���?�����#��@�e��@q�,��������3C���L���`�?3�����#���r����@�e�����݅�|�������/��!��a����4N9Fyi9]��ۨG�6���z(
�i�@�(��ǵ)ҥ�: �?���	#���������3��lI��-��&��_�2��(�"����+8}�]丛ǱPeE8���M��O�>+��^A����D��Q����~�!{�ۋ���$��Ʈ��w�Rm����V��.����O&�8&�x��1�R7��L��Z��M9
�����R?�
��bȹ,��H���~�⦲��s�<�P�3;d��	���y����e�\�?�������}s��Y/y����Ç�s=1����e�4�!�4�-sĪ3]�G�z���<�?R�vĲm,��b���z�OJ\��k&-��.t�.�u(����N���X}��ݨ!�>��V�9����4��^w;�Q����|����/E���������Y}����X��2���_ ������2�0�A��_FxL�����[�W:Ҝm�^	-�#3j/��Ų����!���j B�D��<�����D ��eiE.�EًCU�M֖팇�C��A>�и�9�~��v$�wW�p�5�"����U�9�P��H�_T�v2�����2Jtk1qU��y�սJ��ǲZ���ɘ`(2Z���?{�֜(���{��U#��Ůڀ��"�r��3**��;==�{:�t>��z�j�ې�#�/�]�:���r^ ��i !d���of���yu�w���r�<�4���Xd�В���?ٖ��"ם�_��?�,���@z�k�?6�3^�^,�Hb/��"�펖X5���zYO�s�C��y��g+uҼԳޱ��h���E	��=�Q1Fdg��bwB�5�]��������8�(�C�Op�? ����a�W}A��������(��_�����/����g=�����(ay����'�ۑo�^�pI��!���#�50�y�!�`���@Ac��Q�����?D�����Ʈ6*��m&�N};	�$Y�m;�U�"E�X9�f�����r�Z���-P��V���'^?����?
>]��f�C�W]Aq�?���h��#��O2��Y��G"�����
B.�	�������2�FB��$N�iq4%�Ņl�Dx
D����$������H�����f�����ޟ���?�MFa�I��}FOcr�K�7���\��je�#�ʷje�o�������@����^5�����_�@��A���������I^���������?�(���?�e�_��>p�)��������`^�?��D�����U��A����������H�������O0�	������upT
�?����`���#�j��m���=�ʀ���W��0��2��Qp_�]�{����\��W��D�I������2�O�����G���G�!��?���eYLV��_�V'�My�m�AK�b�R�Ee�\������{������{Q���n5N�d�]��V�f�(�)�b'�r��AW�36�y0���E�M)����Tgm��ET�)��ETέ�
{|����0S3���H��0�{آl����N���N�f@�0+SNO�l�/|1,�ѬHl1 	v"��Ţh��s�Vqw;mv���3���N6�A\��Tw[�e�L�b��x��X����n[�!�-��j���BfX����V�T�տ�vI�*K]�"�T�չ�?�8Q1�}���\(��/vK�6 �"n�Ee��g�L��-W(�F#n��
�;L9�i�8����;Y/��fK��:l��/i�z&�w��ҝ�I�d�;	���4f]��5�-qԚ\��!�uu��\�����ۢ����&d��i���&ql����6���Z���C����l�j ����Z�?þ�����z��� 	�y����$�Z�a�'~��՛��~��`z��8�MI=�cn�+���U�Wt���_�#����U8���JI�����~��(�5ź����4�L'*��N������n�͟^ß_ü��rMe`Ϲ�R�)��4EYzW��<F|���|���E\%��'i@����1Gy��Y�����̞mM1�v:���.����t����lƘ������[CN/̸o�>��լ4�#uM�V��v��.�۽ղ�h�8�U���y��p�N/S6D]Z����I�$`;��(��v�&��z;\n���0S̿�XOMex&��+��.���J��IB��E`<�9]���3�p���H8�q3ӳ!c����㼝+�@�KS�Cl<2�~���2-p��rm����z���^x��GG⿧� � ���_;����3�0�	5����H  ���!����7$���[�������8v[����,_�����������Oc}2���V�Oj ��a0���5 �˅0o���.b��6��L�w�`υ �iz鳇5n�\�@�$���	���8�s�h~^�z.x��Ø,Hs�g[�y:K�݀��r�� �M�)3`^�=����s1mȢ@�&��u��{d���^ �/%q�Ζ�t�}5}�{@WԎ��#���؄X�LƔ�Br[e{=�2avf�}�'�����.'[KK[�����ьu}����X��� ]���:��J�]������WF���!��� ��k������Q3�� ������u��?���������#j��?I��PP��o���}�K�����׎����`�#�$�J�	��x±a�GO�|�I�!	4I%��|�E�Q@�\ �B@�[��M����7�������p\/�]��gMa�Y��#|H�K�����J��m�����7{w���k��]\ځ�5.#z%/�F�d=Z��͜��2aܑF��L�zk7�N�L� �-�p�4OV�dNsS��oo����YU?��K8���:<���UG-��TF���������ߍ�G��_u�J�׏(�95�=�l7���7�i"k�~|���g���i7�:����d��K�Ҥ{����z<[Z�t<�1�	�,9���m����l�2�lN���o�V�G��fR┡Z���?U��[����oE���D�����P��/�������/����/��@�Wq�b�
�E������}>?��zO�������G���;v=�������7���ů����-�kI���&\<������6]w��8Q��:.�-K��&�p����n���qd�#�v3������Ό9;/���M�²γn�n�m���*L5/�ױ��}{�o3��n�|���m�4��߅��)m���碉��Y�G��̲~b�Ǒ�
y��u��t�Ǭq��
�v��u�@$��@�5��[�eN�$��!5�c}4�#lu��tx8���q&��8����r����r߈�̳�6f�aK-��z�p��~�^�:�� ��*��V����g�����?�P�g_�?��!���|ך��_����_�����T�����4�E��������V��_���?"��⥦�����_��$I8����+^�D-������� ��P���P���O��`�KM����:�?���@����N���?��B��$�����_���Q��������W$ x�Gx�ڂ����_CB���������,�?
��?��T����
� ������������yu��_�&�#� d� C��q.b�L�� X��Y>��0���(��y!���� ��~�E�����"�W��{�aq�7.3YM}�ĘYH�F�|jY%=��#��Z&��������
ǛL韇�=7���a���Fic�%�6�U��pR�z+�<bqѥ�����}�L�%�����o;�N�ڰ�����O<z���G�j��#�z���$�Os��GA��$���_$ �h��%�����`������������3P�W��$��L��S����x��)�DID�Q��8�R�pT��|�qB�d���P��p�3�
~e��L��z?[�K�yжXc�ۦf�{BϚ�՟I�4:*������4�[6���Xq��M��ڥ��_��e���ǻ�91I��S�er���v&�]6�wӥ&�(\H��`��������R��?������.�������(�OA�u����A�Q�L�o��_���P1����������AB���!����r�'�?��P������_��3��?������C}(zP����?��G$���� �`�C�����G����:��,����k����}��0�	����A���������H�������?�?����^LY�0�Y�us�7����W��{_緶���FgS��������5w�5�IH��p�x�-/�l�[{�12`ڼ�w����\qF�����g%!_���j�ҽ��7x4T�6kY�R<�{��>M�|���}'�l�biܭ�\������س���^��=Ч�A�H�Bb%��q�Y��:i��z2]�n'Y�d5UW�8{Ήb��YhҒ4�wL��QC/�U�|�!���5��?ܨE�����t�!��a9x�oǗ��׎�j��̃�/�DB���D!�����'������`����_U�����~;����v�W��_5�������GF�?��W�O��o������m�:��#�q���z���,W��KVF������駦<�'�"�w�9���ruu��SN����?9���c3IŢU��o��	ɟTG�/�E��E9���4K�?d�!����ܯ1���Xw���R�F��D�5�I��񞣓�����k��k�7��[.㣩�9��C*��4EYz��#>�RH>�w�E\%��'i@����1Gy��Y�����̞mM1�v:���.����t����lƘ������[CN/̸o�>��լ4�#uM�V���o���o�V�Z��d�mSS^�h�œ����Q�V;?8p�.	���.Jc�ݬ�I����۬9#;�F����?����"������@�c�b��mCg��|pOhN�~�k�L2\{n9�r���l�l��:�8o��&P�����L�ೳL�1�\[�����������	u��ɹ���?z������O��?��GB��?NC��R��#�%b�gB�gpF�O��(⣈b���"�
#��؈�*�v��:���������+����o�O3)�7�M�Ŋ�����pڬD�AKm�6��,T�o��<�G��=iw�8��[��x;�$�/[��]�ے"�9�����D�"�����o R�KN�cw��� P(�
U8J��u�6t?���j�g���MUƇ��Ós���M���b�Ñ���l�P؃�V������)3��81��h�ԩz����iz��6��ӥ���}�����9��[���ҳ����O������|jj�������ӥ��������{\{sm|��{���K���ՉUS����K%�a��z�_�$�o�>T��V�����7n�;����a�?�hJ�rs�M^�큝i\�ճ�7S}R>�o����I~b+���k��q6����ߦ�y��������0�+4�X��� =��_��_O���������������?[����6��ga������S�������_���g��[��sX)Q�>Nn���V���p�_�|���_K�w���h����?r �3�@$h�.� ��r�AW.KK-�^X{����of�gǥě��5��U����GZo��w��Ɂq��Tۇ��J�͠��pR8�T��o
��;ګZ����9Xo�˽�c�.��$28�ľ�8�]�8�������<9-�?`���2�����iZ:J-�8��P��vS_�+E���Ƨf�Ӵٳc��2߿���T��~��>Y>��J��IX�i��Nk�+�ڇ�������R~����QY�>���#b��_�|Ȏ���II+_����ɗtgd�e?:_N?�N7�F*�qz�}w��_zށP�ǧt��kc������O粅���(���㩥���O���II�I�l�f�/�x�E�鴪�b'�����*3��1�HJc�Y,OB9(�y	�E���,ni�Q#U���b���?Ȉt���u�a����(�)F����l�`�H��X1�!UsD5�Hf���m#�hg�>��HK؏6�1ݜ��i�4:s�a�:������#�ȴ�G���gd��s1���&ſ�ԃ2/?��y���������+q��Ml�pqL���d3�ӱ�)�"d�!�M4�LMג��<�Z��ℜB�N��D5?�ؔ�Y�ˀ|�ao�4
�6��A�e�)6����ci��5�fySl��%(�LLS��Jy{1'q��j�/�f1�5�����yKl
���W���p*@3����U�_s\p���=`�M�y,Me�z|��u+�_y�������C�3E�}�{����Û�����@&Chl�(�m���B��9��`�}�0Z�
H B�ͷ�b�������v@�Ώ~�4!O�Aѧ$
9�E�@W�#e�,�������~S�����W [�=(���V�}8��I���0�̉�'Z.J!�B�����R �*�T ��>��S	�3�e �(%�i^�_튑(Ng��FE�$*���N,��gӅ�o:�K��pG=�C>�W����#�N������%8�M_�]}hU�c��#ࣨ����u<$�$�׍(QR"a�!#�q� �TݵA�@Wx��f�g:C	O�t�C��)��l��E�^�͈�c�v)�P�v'��#�������8��qD[���+H7��Hr~�Ld@��,����-<�q�no��d���3��N�$�!Ź�PE�o6��٘�*��d<��0�ݝ�5N����T����X3>�{`���˦���J'3�T
���tj{��Q�8�f��L��D����<�$�`-mD ���Y:S��eZ�)�+G��S�dll�k�	3�ךeh�����R�]�\TJG���~�9Jb)XɛK*vj��6>5J b	�^klZN�Ӌ���Gh��A�=$1���oYL2 �xV�YN_K|-��&�]!��+6�����s���%��ɂJ�T�e�$ݣ����=VH��wY��T�`��tZ��c�K�<e����U��S_rj\��;br����Dq���!0Шeօ�4V����r����k�Wָ7��Z8�֨�K''�Óڇ�ɾ�z�`u�z�[k���v���O�������N�sZ�5���)��O�� �s�k�؀�g��j��NUJ'��V��/���em�j���^����gdbZW`�]��U$	s�$�:Äm)�X:n���★��,i�	<�z�=����/��G�P��$��B`@�r ؉%��Xlu�B������|�����J���J�]Cf?�7/�q</P9*��fu�h�V>;�pzQkT[�z����M1�H����V�rix�� ��0��=���nY�MR�U��c�z��t+��A��Q�~l��O�w��<]M�p�!��4+�z��=ZDؗ��(Ԫ�P��-uk�o��-�K��>�ʰZ��|�yV9��e��G ���bno7�S%�_��'V̉)C�d��������Tx��%�9�`Ns2����b��~\#�������w�˗��+��CW٘�}F�O�Us)~�<�j�c���,w�"�@��Es���9��%��Z�8k�@S�dM�,Gup^)1b�] �O��$����М8f��t5��ltbk���̦�s���Bf���(I��	Z�.BŤFُ/�돰A�;8��S�N�c5�iGRkr��"G����$1�uƮSF�u�r��N��!5�{�*|�Lfvo�@�	K��z�x�e������uk?�֭�d
����\6�]�y��]�ٮ�l���?������v�g����?�z|h�Ou{���r�v�g��sﴱ��0j���8�_��p�6���)�s�_&��m���H/���iF�G�!ۯ���H��5�v�,�zKƖf8�꺧��x���T�2�)xHLj��Z,�¼�/�L�����-�㇝ײ�t+� Pڴ��ډѝWDQ	�_x���7�Î.:ͳv��g��(y%��J��lg�(`K��-��*�#r���0���n�w-eD�\��g�#J��6�xXld^��j\�����;�O�'���w;dKBO�9o�n�4��*������ľ�F@�M\ө���0�N��3jl��6��1��!����.����4�����?|zz�E N���5����>%``��\S��<C�c��_����F�	�
X�*�5�_H���O*���|�2��V�#�����~f����5���)C�D���R��2!Ɔ�<�_�d�]�/�k�E/#"�O*�8��|���O'p����T2'��`���zL���3�aȻ3r�h�!��6B/�j@5��_ "���3��	?i5	BU�Ʃ�m$Ң��.J��E���q�O���I��~l"���P�,;)�^~�0}�9���ꍃ�81�9��&� m�Mb�׾'�%{��Q����KE���b3!C4�h�O[�vw�AfS�����{�����|���?"���u���>�"�(��S���kw�(�?�� heȔ+1eV��7�B��w#��@!\'�ve�4���#�5a����9� ��������o ��N��T�5�r+�9�v�X�I�(��ad��j����o_x�A\�V���������߄�If���Go!�o�����U]Cj�Z��<2�@���E�!�fa@�*Y��3�D��QR\�,A�2��~��Ԛ�Re�>�]��?~i�F��E>�I�Ojѷ"�&�L�˲q�5�����:�=�L�o�sX'�+�^�X����/vb\���E�P=������ ��.��/�+3TDKD�@��b׀��ۤX��b�n+F�:��:���ӭGA�o�i8�U�H(o�����Żd^�+�='�����xX�v�����{�9c�k#{���vZ��.��
\��:nLj}䊕\ghZ�������_I�B��8L�p-���+�D&�_n��NtEc��y� n�Xj~����*�Y��Jj�	�Wa*>Mg�1UhCj�;�O�	S8�V0VD ����%����M��������RYJ{IV���I���I��w�X_��v��l:�2�\~W�I%�M*4�[�{�T��=���
�U�<
ֶ6���gF�gL�1�FO�Ԯ6Ϻ���~���q�>]��2�ͮ��K�9�7hШ&+��WO�$�� ����s�
_܁yV��E�,��'vf�ރZ�����`��]J��
��2�S���x��E��Y�#�aّ�cB�TEtgFP�h�#�j��Ws��3d�L}+\�f�����M^J�)$��Fp�$�6�r��� )���ݦ�t���-Z¥�lh��o*�����L���?���w�Wh�8���j:�L�aJ�����Swr�V����~�m��'�����|n��_��6~L�a��@�����G�ʿ�ڮ�?J����럱��~l­��[�?�����P !�l	��Br�6
����$��M&�xۑ#�����[�ٶ��~��t��v��[?�����N-lI"�CL�;ߖ����:c�_;q�F���#�!���8c*N���[i.=���5�H�-�!�78�<�σȾ3�;Y�P<Љx�����K����t#�\"���|���G��M�?J�nR�{����d�WxJR��3����ߣ������9��W�dx�,:��@� �KT.�{g�|�c�u�������N��V�q}�
��Q6ic�8-V�{�7���������������=��d�Q�o����J�38��t!�ʦ���e���V�?Fz������ON�}B�ʣ|�����3>��"�z�~l�����+B�P�B��9(j�1�`r�yA�;E��?wLS�fv�d���kX~_~v�E�C�z��^$�_���*��
�%��^m(��@Yp84w4Wſ��X��E�U�y�Rq	�%���Jc��[[B����& �PL�{m�0>�w���E@Q�g�����&n%ˈ�S�C�����4?svd.*�!X}�̜ΠT�����Q��;F\~ʈ�x�Ed
B�������`x;�'�Jx�~��깎�x�W��Y�ZЂ��+X#F~]"/�� ��ap $�a�x����>��c�r�|��z_3�� ��;N~�P�~D. �^EՅ���T���3��W}x1 o�j�ۚ�&q� /�ɮɓն�H�w|`T���ά���!�_����L����ڄ��5o���hc�I�����r��� �,���w��P����pؘ�ks��B�24-�O�Ӱ/��B���F������~� �2?��@�2mG��As��5�����elj=��4dD�,�d�.���N�e&_C�p�'MD��v�,��<2���p3N�ҭ7��Y;��8�����%~,�J�'`6�L��kZ��,�yd���0����|E�O�r��٤����!���J)�~}A��Jv��<���M݌�E���_Qq�B6!Z�"�풪Z̶×�W��z薩�/��
|��<s�و'_~�Em�)����p8H�C�h_�Y�c��=|}(�Kh������Q�9u�1�G�F��e �1�F�aϕ��м ��`k����wm1�ciy�w�����L���Ҕv4��؎/�Ʒ$N�$N�+�V��8N���IF�������yA��7$V�WX`X��x��x�#عU��U�U�q���RW��ϱ���������}�cW�{�23�}��g�.?�nݫ�p��e��m
��^���V㸋�{xLq�&ܖWS�"�ݻ�B��[��^s�����.~��خ�\���խ+���Z\D�w_Tw�l]��ENt{y���������Aj�DR�<�`�ef��x����bc�{�:���|!�ɺڬ6ںP&+�x���N�g��M�m��i%�X�(�B��b;9�J5Zw���/Zv�c�%i6V�mx2���a��h��#/��Jg�4ۋ��⍓��3'�Sb`K��F([�s7�`�B|���,��5���z�����5�����.k���8����$���q<�������~���ᝃ���O�ţ�O�%��P��a�P*�T�(�Yobj���f�B1�T4�0��TS��)
��Q�Gq����{���C4����<� t ^�l�ïp�������?�q�ޭ�y|����u�����u2�ށ^;���soy��[�Ke׸q_~�m�[�˛��:yMi���*X�yw��j}�{䗸��?9��6.Y��"���O��`�����A$��?�����������7���<�����O��������~� ���_9�u��?Zp�+��u��h��!FD�����
i��!��z#�P�p��S)��hAQ��D)�qq�:��y��Y���/�$����ɟL����w�m|�~���-����4��oA�y�	�����\�o�y����B����g�����Z6����"��i��6��Zw�[��l+-�l3I%4|�.:G�]�:�lN�8��̽���:y���F����5�Q�'�D�|�u�WE���--WQ~ίHk1�f�4*��S�-�b���e�e��)bB��s:�L�]�i�$�y�ᗷ&�N�����Z��ջfK�W��8��Dvo��V�U�f�*�����sR��q�_���%�ZF�z�8���-�'�/�p��f��~~�X��jb�����M2r��TN�it$!��tF!a�JΘn#=h���_�mGT��2�3-���͑��t,����D�S�y,����3���"�V�[J�)��s�cǻ"]��D�L���v8gQY^V.:��3�9�_�Ȗ0^�%=����z���L�AԒ���a�D*�Y�ju��� ;�|�˻��ӂ�Ά��Yl�LU�u�S*j��.Ð���QC��Tz��B�b�E�P&�B���q+JO�uB�N��0%�5�RS��F��)��~����f��'�ό�V)�5�L|֫�F��ҙ���ܗ�������h�n�P�+7I(��0����W�V�8}��gj�҄��q45e$$ޙd��KO�LŨ��m�&�(��$��ҝr�4��fUIѩ��(.�5��w�h�@
#���5���u'Ֆe&-�Xx3��^|G��6�sW��t�5eL2C�a>�qR�A�[�TA�f�0#DM�	LQ�gS���YAb�QJ" �냺\հ�2��2nY��	�V��E�DM�FX��"z�Lr���z|_�G��qTJb"��ƌ�(r����E�ޙ��˅�Bw��q"��N�牝�F�𓊌�)�=G�L��y֚�;�/b�����F|:�칉�^���^[� O�\O�D��� �d?������X˟J�9�c����82e�t��d"�A��rQm��IL�Q��i��+I� �(+*X-�*W"h����&.����?O#~�Z�n�X��`PE>3�W����Y�n�D%�DZ��y��IӉ	Fe0�c�!]�q';b����e�2fx�NF��
t%M���$:��ǳ��Ak��Ṕ��f��d��(��/�e�-�1����k�@wܟ�^:|ų�V�����»�k��jgl,�������֮ݚ���E�U׶<X�����^x�I����G?��o:p��2t�5��\r�o{�]A�}��7�V�{�'o��J}��}����߽�9��٥T���T�P�e�`G'Yyd09�<��d�B4������Z��8����,zzޫNlI,��ޔ_0���,��s�\�:Z�6s�%uI���˱O3pEd�k�z仭� OE)˴���JX̱��ɰ4-E����9K�c�%�!���bm	PD+OR��d�]X�W!��jF��4ۭk�w�i�G�fy^�ƒ�!���u@E��K��.d�B,+�5#��p:�^��i��m��L{d����]hp�d0,���y�`�n��f<ĖB$i+���e�錫�
�V���9�'��I���mT�Y'W���U�vK,k�T����x=,�����W	��z���#�k"�ci-��B���.�$V�,��3�lu.��~��I�z�r}�(K�dX�]I��|4���V~~F�����/�������
rlN��
2�ʹ��lf�U8���\u�i�יe̞[&,˸M�Sj���tם���:~�������N�l����D8�6!��ȼݰGF9��'�b��9���L��I�U�2�p�S6�b_+�cL>��5'߭Q�k\$!G[Q�mwµM��LF�G�p�ig�(�KE�i�I-'K�a%G��z�;�.�0A�%��l�Cd�5H�6��� e�����xFT��%�E��8�V�9-^+i�D�#}>Y 'I�D���U5�OL�yٝ0:'c�x"��	C�I��Z3��T�$aFeV�{��\��S��y��Ȟ �13�J}�b�c��t��D�3Z�S�v+HzN�^	�il�?��K0b�Yp�%��0�z���Dqͱ�0�{��Z��m��r�RHZ�XRSl?4"�B�9<e��<5��p�ϳ#�YF���Tt����>��4U�f�8c��a��R+1���� �yk�I��
��(����ʃH����Q4$?�ION�		�5t�rC�Q01!�bލ@a�V�(DDǒ�T���Q*�5��T�i��tf����
!��d�bXa�´
��n�bjKs�Ƈ9̜ɵ�Z�
Y���M��^9�K	���n饯A�n�n��Ѝ�x�s"�*�O���?�tѼ6����a<����Vs5k4yh�{�𲷉fS�|y��zz� �{��1����6u�^�����n�Ǟ�w��,d%�4K�M�@W�&]��<�o�{	e�2,�6u/@T���`E���||eq�b+�
�p��"�{t����Mu�[�f3�C���'mCz�-��S9 /-��	���7����
���q+����MT���q��t9�'��"���ߝ�UHԣ͈���8yp�h�3���^8����f�0�U<�#��f��Mo�lAs��t��y��\���f̞�Un��m��\���H���/�"Y7�A�W���Ⱥ��uS7�#�~�G�MQ�'ʽ���Y7�E=�n�zd����:���z����:�����?L�,=mX��>��!�O��;��B��K�ϩ?'���a�wa2�ˎ�?�5��M��������xiG���_� N�� �@�����\�I�_]�W�V��ΐ�qEE�%�iY�G����J��z�X-&vxM�k�q)��Z��+��T*ݙۖݵ蜃�G�3��D��eA�h�[ߺ{��u�g~?��nj�-�a_��%�ߝ��)�ǉ���	��z�V�`���7��0�a��g�?"��v�쿡1�����9��������2�˶(���A_��0q�Q<�P�t�t�I��0et��]P��%��T�L�l�3�i�<��,t�ruI����	;���|_,v�1�%C��e�^���wV�gR��1SË�7t�U����X΢��t�+�gi.!�ZWc�VOd���37��S�\c�oG�RW��"(���z�?0�=�w������N��������.�<�;����U��X�G/�k0��{a�ad���	�{�/S&�}���]����?技��w���9��h����n��2�^��������_��S�����������?��.�'����y0X����;�G���'X��	���Ue;���^�þ�'�?���_���@��?���	��}Aؾ l�ӄ��{�>[�����#��v?�?/$H��/���������s��;�~�����"����?���� ��ND "�������>c/�?>���$������m��- >#��_l�o/�C���H���������`���?y��?��w� �R�m)ȶt�lK~��g������7���)^i`��������������{��� ��������?����{���D���?���6ٽ�X��!��_l�o�?������A���`/�_%P��z�l���>�$�&�j��T�H�42�!*F��f�R�#8��LF���=z^��������|��\���ӿļ�s)s���V�0�!<�O�$�p����%ݞ�Y�]e�E��͠�,Y-��3(FGᚮL�R��5�<	y%�L�.����m��x͊T���O�Q�9RY���\?i<9�ˋn��>�� ���K��f������?������~��������Sxq�����Y����h|���r����!S!�R�a���YͲ�؎��z����R|��md�r�[W��<<�u�HE��Hx\��&f$��d&QÃT��H*Lo��x�1h'˖�@;�N�#eʳ��wU����>�O��*����weݩ*��>�+�c雇� ��
�����������4{�D���}��v��SbL#�YsV͵�W����A�Wa��/����/��������,D�?A���?x�����k��-'�v�$�7���3�кR���_u����矨kUml2���^�@m�z��z�ۦҖ�ٛ��hZhu��i?�u7��'-=,I���a�J[)��	u.m�"�6�p�nШ�n�%�$r�^���q����׵�����1���Uj���-������بjn�?�)�#Ms�������=X�E����o������_�|/%�B�Y�WUg�ʨ�3����A�>D
��������J�y�M�#93*�U�O�4�w��uI�k�_n�y��E1o&�Z�#R;Η�|/������������H���p'��� ��?4y$����E�?K��$	�p�?tx$���}�9	�?x �a�#��������#����?�y �����#��Y��#�13�Ü�@�����^�?�� ����/���������<����[�������f��9���3������� �?�����}A��c��U>{�z8B����������/����/ݙ��,���O�<��5�x ����,}g�W �ǁB���9X��� ��/�����0��PR(������f�'��0�����B��������������?@���P������
��,�ڐ� ��{�?"�_����@��yl|6���7�������[�_ׯ�/�Է�M�6���lm��������5�p���f�ܞ�9��2X�O�e*�TB=}�D>�۪r8������iC�t�EiS��;I�k[h䰫�/q�0-SVv�Ȍ~�Gigjs�i���'�m���n���^B]�@�Mu-���N�杋C4���b$��X�A��ih��:5�J��-M��rX;Z�݊�	��r̮W�e!3����<�S6�E��GC�ur��6v�� B�1w�?@����9d� ������ߙ�	�/, ���9$~����g��c�������?���W���搅����D�?���@�CsH� ����a������?~_�������"<��f��/�����#��9�N�G���^� qR�(@���	G�l$о����F,K�J(0AD#��"!}IYb'����g��2H�N���P��/��c�/�������556T[�M��5�6�\>7+���s���t��{����ԝ�k�o�Ɖt��&}�1b��N7�;�z����L)M;����w*�6C��8ĥ �!c��Nr.���b��̅`��$�r�I]<�3�4?{�z6;��y2����Ј��*n��S�����߻yQE_p�@���?�C����C߂A����8�����0�������,�R|K�������G��d�_���6�ZyBSzy���\s�]��U��-�e�������I�z�-�$��7��5�,Wr��T���F_�\_�kl�<99��k�z��L?���)���49��e�k���� c����"H<��8P������W����A�Wa��/����/�����E���,$�?A�@���������O�ל�8X�Q�-��A�m��M����O= ?R��^@��e@i�{�4�l��[�̤�T���鞖{��i5�+s�O
�(s�|,K�I��]o��Z���Eg5A���#�Kζ�-�mq��̣�:OCj^s�t���Z�F>�4׫��uO05U׫j�]y�/��W42����c��Ȳ��<�.V�/�V��t�����5:�����*��bc�.o��xX_3��Bzd�~|m�S/R�h,�i��@�N�:�T��y^O�s��z�i�ONԋ6���&�W���H%kN�38�>[����8v'ވ�0�H��8�����������	�q���H7�"��X���zz����ߛ�_�(J��q ���/�����OZ�$|����\$����7/	RF�/ �H�/_	.�`"3�XF�<��
�]���-����<�Á���Uk�*1�Ю
�vl���b��e�t�;���V`��Q���S��˖�j�~W�@��WA����[���>��z�C���q�߿��_� ��� 	��
7��"��� ���k�C�ɗr�D\���ü(ͳ4+FQ �!N��@��W�3�Y ����������t1���8�[홿�i�Ov���ޢ�>�}�-Xф�������ƕ_���߉+_����~D��4�_����H�����_�?@��A���������������x����H0��À���]�����w�?�^�?���	��n��b�������-�u��������?���,M���A�,�������C@� ��/��o����/L(���`���������?��*���})�%������f���� �����l�����ȼ��x��_8�V�˝W*j�z��z�oMe�+e˺R�t���*�3�ζ��T�1,ey��}�E׌SE�.[M�`|VB2�[s�bG�����2�'j4�h����1���񛧶�s���^��[�<��z� u���������������`s`���?������Ǜ�/zER��!�v����E��I-\�G�./i�:7�'m5in��f95�B����$m0�̙Z��,�e���V�tj��OM�ժs�2���O�<Q�"'��t��ٯ�5ڥ��T���U�!�U�\[��V�~�>�z�O�r�� �&��2ްb76Q��J�������-ڮ�q]ȧ^<��psj�֋h�l�שC�s��Պ+�ݼ���6BFlg�Q��¹4kz�'|%����h��e��'��0�zYG5ײzH|��:f�]�JA��-��n�����C����Y���� ��{�?"����w���X@��l|"H��ҿ��a�[�߼�����g�Z���iR���f(�6�b���珮�2{����0�����F�>Kk���c�֙R���'�i�ؽ w�k�,�ճ������c��c�`��׽���ʠ��2^leD�F?nS���b�34��;ژ���{��T��ˍ��2������M� 9�٨1���O�A�W�j��bЗ�/��ڨ�Iw6li,��\���d����Ǽq2�1������&�P��8��zok���/{��sU���.ϳrwaW���vc��4KS�]����m�ꆁ�Z�]�����5���n~����2:VmëXn�O�HU�x��F!/��"��t=.I�%������ʡ2)�V��f��O�Muc$Ȱr[��]jطkmD�N^���_���W@��c����/����@1 �����/������X@�?��� | �������o���~=�/�8�7��Q���gL/;������-�����>ڃk��7 �Lm�� ��@�_� ��Ǟ6��6��P�A��4:�����R}�5�Y3�ͤ�����P�6ʠ�.&��MY{XWg[��,��z�w��Diw�I��W|;@=ޓ��5*UT���x�s8[l��k-���9HK̹����>�#�Tk^i1�ި*bȬx!�V�yz^]��2;	\V�aQ��aSR�ҩ-��0[��L��^k��	�(ZDQeu�ŕ�U6�����]�����������_�� �	��������?�����_�����2��p� ��Oi�م�� ����H���{���, ���"}:�D?�I�h9��0
x_��B�Dy���� 1����R�L�{?H��{�����G��i+o6��fVVf_��-�Ow�a蘃���ap�4�5�����*��9����*�H�s�_U�����_x'�#���2�~�5gqe:X{�;�bCjY����^���*���Ʈ���_	�?��,���}	�?���@�C���@ �?�޿.6���A���+���g�R����Һ�PY���ڼ=9w��wV��1;���FO��.�t�e�U걻�Ԛ̖{ݍ�S�r�	�����ֶ�������(9�궽��v�c�r��\������=5�߯������߂@������W��H�A�Wq��/����/���������,D��?��������_����C�i�M��*;q���� k�{�����~��{�vWi�kcml2�����_���%Mo�HzA���V仵Q��t�ᩉ�o3��N�N�q`�f<�N�A'n�Źz>g�6�R�9͚���g���!'��MN�j�A�t��=�n]��w�����彰�b��]�:u��ԛ�-��r�C�<�5ݗ�s����y[�L9��m��5��b�@��bդ��mݞ�X�}n&O��}jul�Qw�WJfs1n�3��'�V�hc1�x��JEe7qR
�p���h������[+@��c�;����>���$��������� ��D�p������?�w%����E�?�p��.x����\���������
�_a�+�-���7�O8��<�F��
���[����,�@�� `��B���w����� ������?�������<�#^H����H����;�È�@���7����?X �_`����-��	��������p���� ��'8������C��1��g�;������?�\����������������?��������,��Q�/
��}��ii�&����(�J(Ѳ(��'4����;q$���O�몝��A��y#	q��6���ё������)�6.��m`��څR��+�����Mk�,d9H�i���0:�����O��������z_�wS��xء���н/.s����z�}�Ve�f
����n唛�.5V��=;��V�0$��bfq�k���1��:IK�f}�_��$�eMa(��-�X�v�l��Yv��8u�����?��Na�����d<��>������!��g������S������x�� t(�����&
����I���x�_��/��w��?�������С�?�ee�� �!G\F�v��)#&�BMV�\�Ra:CfF�ʤ8F��TH"�@V�%���S�����������������6�I�xG��:��d�:������Lc��Ʋ��6�n�|���K�Z��θ�T,RV��t�3�D��j����1�#�Ey�|?X�S�촯Gﵜ�Y{���ٰ��<i����[���8�<�x��Y�m��J������T�?�����?��!�P��������pl��?�������_���ё�?�8�)������Ԟ��8�s:���qD��?�����Y�'���	��~��P����?�L����������8�����������\C��q,���_��;	��dc���B'���3�A��S���}�%������?t���<���,��"x�(M��M�h��v����ϻ���G�:��:�a����/���k�}�Q�ιsi��˒b���%�U�N�w�Y�M�r*���:]γ��+�l�$��ﳹ�uW�Gl} 8ʜT����ժ���Į�*���}B��|P�\�� 6������Ə��F[�Ҙ/�]���2��t��i��`Ά�`<�8G�1B-Y(���|��dҁ��&YA�eЈ��l�3W+e��0��{�ެ6h^���t��=����B'`�m}�ؽ��Q������I�jO�7���A��?>%��t
����h6��A��O��O��O��O���G���>~����(��m��$�?���F���<�����?������^]��������o�5�n�j�+-)V�g���l>���^�U~�����U��=ߊ�h�#Nkc�`ΐw��}i���������=C(�,��[�~@g��e�;R!��K��f<Vnw�NM�\s��v$�6&*����X�U;jP���j�D�;%���&a�I#�A����e�X�V(�1L�f�����?J!�ȓ%^(���RhR��ݩ��ʂ���r��ҹ1�ou���U��{���r�/�e�m�*7�� �����[�����V=(O:�R���}�\�֏Ƕ���j誷�?�H��竢����9��e�$̜��sBI�N�2ʳ���Ւ\�;��OW�:Udeٯ��C��Љ<��U�+��"떛iB��;�3�lF�Ϧ�����s�R
��~7�e���Kz;UN۳��J��4��RP�r~���U��4V"��Z�����L'a�Q{�����x:�o
W�g;0���@���k�����Y�������)�6R(N�(M%Ӕ�ʤ6�"S٬I�*�SՌ�2iFNs*�(*ɨi5�d��d����S��}�����a�=��w�+��div#�O�҄k���s�]�g|��Y�I�zs�+q}�3���ւm��4�{�aV*wW�ܧ�y��+Cgz�l4�e�g#*���tW��\�[i���5e��Sz��ֲ$k������)�����ǣ#���/��Na������I�|�����?*7���cw�/H�����w<zO�ϯ5��_��V_��6�[�4?Ϧ�ӊ#��d8���6tm��I&]�z��H�\[����v]����mC��%�:��]���s�^�|eBq�w��Y�\��oJ<Yf�e������i��t�=�����	��w��:�����_ǣx�W��+������?��w��Ol�N���g�����C�k����z������z���?��*�%�r���mr����ym���j����f &��= Ķ=�w 2U�B�T'�^K��� ^��7#�mu�|���L�޶�)9:#�q�O
��T�[�v;�*��*}��Z�
W��%�Kծe%�� ;D�[әdk�5��C5 �as�}���M�������f7/U���Ky�?yÆ�:-�Ť�7`���	9%C�{�5�g�^�dj7u�]wkl��VE=:���W�s1o	���jZ$��(��*_��bI�ɲ���Ɍ�_߫��`P.
�1�J��ӣ��;w'�
o�M¶]�D&͛�̮پwW�g})Ԩd5�\��F�i4���?��g�e���i��w�N�$��!����1��JB]9��M�p�Z0�-A|">�v#wsQ1Th��A�3Ft.?��1��$ʇ2^�!nguG�Nhj�g���Ȱlp {�m�dK�KG��3��5�s���sI ��1�u������*��=��l�ma�{��9���PG�!hD�h���PcB4l!�a��ڄU��)ڮg�������M{�,��������W�>TxC�������h��0�]�~��xc�.TC�l -Y1!J�HO禡R�m#�u�a���;k~�D�;�\% ��<�G���@0ȸ('�D�'{��H#k>a���l�q�.'�zy�]�[Bs�c�
���J(�� M��ַOO4�/-x�Ծ��8�~|6
g��2R�|-����mE��B�l~�'��1o�<$,�=h#��14����.�g�j���.���{4:�.�˝�.���Gb��o��*��o�ξ�$��m�CyQ��o���{V���5-�NH��e��α�-��J|�ho�����6J3fѠ�+p�R���ζ��=�(/��ܩ��(�fp݇�.�EB�o�jH�< +(��*)��B��ǁ�F?_�ign8ц�� V����5�xcu�T�j��.���'��j�0<�AϵĴ�)�kL!8���jg�S$��-�ڈ�����z�K\K˟)hD5gB�%|����Ml�{x�4,.��6���f�n���x�Q��<�W��?V�/�1���Q���4��F��w�e{`�{>�*��H�Vl�v0����֐p�2򕡎yG�qYy�t<V�ӎ��P������m����~��tv0D�v	��%�n�� ���2���o�g	ӷo(�ZL>N��x��8]Z�AgGB��
dU��\p�fcY�B�łq�A5
��d�^q���ہg+�aj	o����+�?�R���M�����9:� �:�.����Ğ`�'��@�Z%�V�n|�x����Q>o��]�{d {U\K���,�b�Q.lߛ��`��$��B��'|��űlY�ܰC�\'v��L�(I,��.����:����#�뿆��ht�X���_�����[�$�ׂ��Q���������F�FX�sȞ�أ�Ř�:��ǫ9tL��H(�"�ʗ���XD��`���Z�ma��1β��X�JWI�ɽ��2������I-���#{*K|��S8�/U�P�f���S�_PY�X92Mk�I�Z������b ���#U�#J�F�,�
���Қ2RFٴ̲(�i�֝a�a��
n�qd���"���z	�1E����Dv5��nj�on����xN���XRYYI�dEQH6Cr��Q4dUR�ʲ�N�Yȑ�t2���3�e�d&YRrZ��c����/ÿ� \h�����M��+��+ݪ��|kk�C`a?:����O�Q�u0�&>}~O�W4v���Զ��I-$��&���m�^�H=�r�A��_�Vjw��˵�v��L������.��R�X�]a	y-�~��X/Y/7J�+�v���Z[,���ܹR�y���ƿC&��L��z��%H�s/��s�']GM�ȩ�P���ծ��[��'��T��zN��H���馻v��j���汥����&��!��>�!T����������<~�m�.�[�B���\Ij=��X�K5��{��DN��ݬ��T�5�Z�ʷ��e2��q��Bv��o�m���-�ᓸ�[$��i�nލ��ЛH:�gu���2z�Xow�z-_*�֤N��*WQ�6jt������::��7��Pj�=t�I����<��+�g��#Es|���t��\u���_�w�bNX�i}�� ?�)��l�}W}X�y�Gq�ź���aXW#�t�*L��`p
�R?��L�y��3~���d���pc?���B��CKso���Н/͔��Z$0m�c�l���}�ٰx�8OF�ߣ�p�mUP���3��0��>��A~�ŵ�17����eG�+�L��(���E���h�&��p��A�o���>�GR1��"�c�چ��Kb���8��;�;���47��&�vr����W	Ա��$��_��#��b�GV�h��;^�D �r��*A`�����j ���O�}�A|�]�D���|;_��_�恆~a����X!�y��	�QS�9ܕ�!�Ã��j�*��ك}U:TS�� #�<��8L�*�̸����ًhQ#Ta<;x��� �h��K&��9��4�V�|����t�a7��h��M�u��p�Q��U4B/�~��ڙ�󗝛 #�_���W�h`�ΦKMsPM([�d�_�ފ��g��1���?ņ翧9��C#��S,��!���0A��=�sT*a� ��-d��̜�,���8��s°�������0Ed�^�d���!��,^���x��A�u�_��wU���c�V�P�F:�V�� ��#�o�����ۂLP,a������oI$�I�7���ܬ�cݾ��0�_ Sp�O���@\�|���J}�ey��ŅQ�?���+�M���+F[�T;6`����F�K[)j_�<c��@���;����&�#��{!ػ���w� 4�� ��W�*NC���r�$�M��������ޔ,�5�R��Zl��N�:���ZYG�if [�Âz\r�n�8w7�{_F�Ȉh>߆����	E3<\���g�j3����>��!4��&�P�X|��sx�����r�K�
��e1���")���A*#���c蝋ijo|JŲ�J&p�8��RPL�O	5���|�m&��@Z�F�9W�x�1�T£����Ԁ��K�e�޲)���=���ژ�_+��%�T|�E��%�7y�L��4���xǱ,���	a�2�*WOvM���hj~٩��϶����
{���
z�cy#��w�}��	�����8���������}�u;=�|Q]�^�^D��~�J���N��2��2s�\=�t\�i.5w�����t4�C�2�V\}
���iP	�F�Cݺ�7���%��	�F�ky��_m�e��h��H�����jDY���[�R�UQB�z7���á��ɑ�����t�Y;����;��*�sl�����BW���������+<&�u��r�v�+�Ƿ�_"�������/C;@K�џ\�1�kd�tgU� �k'#Z+�E'7���լ^��+�\�I��%���W�%�犩��?Vx�hncM]N��'B�DN�'���2�m��I,���1(��9?@�l�(����I��`0��`0��`0��� =� 0 