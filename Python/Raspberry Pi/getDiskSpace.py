import shutil

total, used, free = shutil.disk_usage("/")

print("Total: %f GiB" % (total / (2**30)))
print("Used: %f GiB" % (used / (2**30)))
print("Free: %f GiB" % (free / (2**30)))