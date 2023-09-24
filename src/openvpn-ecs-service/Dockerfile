# docker build -t 366007218587.dkr.ecr.eu-south-2.amazonaws.com/kaira-openvpn:latest .
FROM kylemanna/openvpn AS KAIRA_OPEN_VPN

ADD ./.generated /etc/openvpn

CMD ["ovpn_run"]

#/usr/local/bin/ovpn_run
#docker run -ti --rm --cap-add=NET_ADMIN 366007218587.dkr.ecr.eu-south-2.amazonaws.com/kaira-openvpn bash
