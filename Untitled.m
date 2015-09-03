
obj=population(2);


 j=37;
                count=1;
                ff=1;
                while sum(obj.chromo(1:ff,j))~=sum(obj.chromo(:,j))
                    ff=ff+1;
                end
                for i=1:ff               
                    if obj.chromo(i,j)==0 && obj.chromo(i-1,j)~=0
                        obj.charging_locationx(count,j)=obj.currentx(i,j);
                        obj.charging_locationy(count,j)=obj.currenty(i,j);
                        count=count+1;
                        i
                    end
                end
     